# --
# Copyright (C) 2008-2009 10gen Inc.
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License, version 3, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
# for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
# ++

require 'mongo/message'
require 'mongo/util/byte_buffer'
require 'mongo/util/bson'

module XGen
  module Mongo
    module Driver

      # A cursor over query results. Returned objects are hashes.
      class Cursor

        include Enumerable

        RESPONSE_HEADER_SIZE = 20

        attr_reader :db, :collection, :query

        def initialize(db, collection, query)
          @db, @collection, @query = db, collection, query
          @num_to_return = @query.number_to_return || 0
          @cache = []
          @closed = false
          @can_call_to_a = true
          @query_run = false
        end

        def closed?; @closed; end

        # Set hint fields to use and return +self+. hint_fields may be a
        # single field name, array of field names, or a hash whose keys will
        # become the hint field names. May be +nil+. If no hint fields are
        # specified, the ones in the collection are used if they exist.
        def hint(hint_fields)
          @hint_fields = case hint_fields
                         when String
                           [hint_fields]
                         when Hash
                           hint_fields.keys
                         when nil
                           nil
                         else
                           hint_fields.to_a
                         end
          self
        end

        # Return +true+ if there are more records to retrieve. We do not check
        # @num_to_return; #each is responsible for doing that.
        def more?
          num_remaining > 0
        end

        # Return the next object. Raises an error if necessary.
        def next_object
          refill_via_get_more if num_remaining == 0
          o = @cache.shift
          raise o['$err'] if o && o['$err']
          o
        end

        # Iterate over each object, yielding it to the given block. At most
        # @num_to_return records are returned (or all of them, if
        # @num_to_return is 0).
        #
        # If #to_a has already been called then this method uses the array
        # that we store internally. In that case, #each can be called multiple
        # times because it re-uses that array.
        #
        # You can call #each after calling #to_a (multiple times even, because
        # it will use the internally-stored array), but you can't call #to_a
        # after calling #each unless you also called it before calling #each.
        # If you try to do that, an error will be raised.
        def each
          if @rows              # Already turned into an array
            @rows.each { |row| yield row }
          else
            num_returned = 0
            while more? && (@num_to_return <= 0 || num_returned < @num_to_return)
              yield next_object()
              num_returned += 1
            end
            @can_call_to_a = false
          end
        end

        # Return all of the rows (up to the +num_to_return+ value specified in
        # #new) as an array. Calling this multiple times will work fine; it
        # always returns the same array.
        #
        # Don't use this if you're expecting large amounts of data, of course.
        # All of the returned rows are kept in an array stored in this object
        # so it can be reused.
        #
        # You can call #each after calling #to_a (multiple times even, because
        # it will use the internally-stored array), but you can't call #to_a
        # after calling #each unless you also called it before calling #each.
        # If you try to do that, an error will be raised.
        def to_a
          return @rows if @rows
          raise "can't call Cursor#to_a after calling Cursor#each" unless @can_call_to_a
          @rows = []
          num_returned = 0
          while more? && (@num_to_return <= 0 || num_returned < @num_to_return)
            @rows << next_object()
            num_returned += 1
          end
          @rows
        end

        # Returns an explain plan record.
        def explain
          old_val = @query.explain
          @query.explain = true

          c = Cursor.new(@db, @collection, @query)
          explanation = c.next_object
          c.close

          @query.explain = old_val
          explanation
        end

        # Close the cursor.
        def close
          @db.send_to_db(KillCursorsMessage.new(@cursor_id)) if @cursor_id
          @cache = []
          @cursor_id = 0
          @closed = true
        end

        protected

        def read_all
          read_message_header
          read_response_header
          read_objects_off_wire
        end

        def read_objects_off_wire
          while doc = next_object_on_wire
            @cache << doc
          end
        end

        def read_message_header
          MessageHeader.new.read_header(@db.socket)
        end

        def read_response_header
          header_buf = ByteBuffer.new
          header_buf.put_array(@db.socket.recv(RESPONSE_HEADER_SIZE).unpack("C*"))
          raise "Short read for DB response header; expected #{RESPONSE_HEADER_SIZE} bytes, saw #{header_buf.length}" unless header_buf.length == RESPONSE_HEADER_SIZE
          header_buf.rewind
          @result_flags = header_buf.get_int
          @cursor_id = header_buf.get_long
          @starting_from = header_buf.get_int
          @n_returned = header_buf.get_int
          @n_remaining = @n_returned
        end

        def num_remaining
          refill_via_get_more if @cache.length == 0
          @cache.length
        end

        private

        def next_object_on_wire
          send_query_if_needed
          # if @n_remaining is 0 but we have a non-zero cursor, there are more
          # to fetch, so do a GetMore operation, but don't do it here - do it
          # when someone pulls an object out of the cache and it's empty
          return nil if @n_remaining == 0
          object_from_stream
        end

        def refill_via_get_more
          send_query_if_needed
          return if @cursor_id == 0
          @db.send_to_db(GetMoreMessage.new(@db.name, @collection.name, @cursor_id))
          read_all
        end

        def object_from_stream
          buf = ByteBuffer.new
          buf.put_array(@db.socket.recv(4).unpack("C*"))
          buf.rewind
          size = buf.get_int
          buf.put_array(@db.socket.recv(size-4).unpack("C*"), 4)
          @n_remaining -= 1
          buf.rewind
          BSON.new(@db).deserialize(buf)
        end

        def send_query_if_needed
          # Run query first time we request an object from the wire
          unless @query_run
            hints = @hint_fields || @collection.hint_fields
            old_hints = @query.hint_fields
            @query.hint_fields = hints
            @db.send_query_message(QueryMessage.new(@db.name, @collection.name, @query))
            @query_run = true
            @query.hint_fields = old_hints
            read_all
          end
        end

        def to_s
          "DBResponse(flags=#@result_flags, cursor_id=#@cursor_id, start=#@starting_from, n_returned=#@n_returned)"
        end
      end
    end
  end
end
