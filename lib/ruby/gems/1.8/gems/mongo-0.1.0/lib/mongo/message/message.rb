require 'mongo/util/bson'
require 'mongo/util/byte_buffer'

module XGen
  module Mongo
    module Driver

      class Message

        HEADER_SIZE = 16        # size, id, response_to, opcode

        @@class_req_id = 0

        attr_reader :buf        # for testing

        def initialize(op)
          @op = op
          @message_length = HEADER_SIZE
          @data_length = 0
          @request_id = (@@class_req_id += 1)
          @response_id = 0
          @buf = ByteBuffer.new
          
          @buf.put_int(16)      # holder for length
          @buf.put_int(@request_id)
          @buf.put_int(0)       # response_to
          @buf.put_int(op)
        end

        def write_int(i)
          @buf.put_int(i)
          update_message_length
        end

        def write_long(i)
          @buf.put_long(i)
          update_message_length
        end

        def write_string(s)
          BSON.serialize_cstr(@buf, s)
          update_message_length
        end

        def write_doc(hash)
          @buf.put_array(BSON.new.serialize(hash).to_a)
          update_message_length
        end

        def to_a
          @buf.to_a
        end

        def dump
          @buf.dump
        end

        # Do not call. Private, but kept public for testing.
        def update_message_length
          pos = @buf.position
          @buf.put_int(@buf.size, 0)
          @buf.position = pos
        end

      end
    end
  end
end
