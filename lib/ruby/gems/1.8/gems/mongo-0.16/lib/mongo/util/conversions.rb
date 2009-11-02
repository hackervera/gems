# --
# Copyright (C) 2008-2009 10gen Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ++
module Mongo #:nodoc:

  # Utility module to include when needing to convert certain types of
  # objects to mongo-friendly parameters.
  module Conversions

    ASCENDING = ["ascending", "asc", "1"]
    DESCENDING = ["descending", "desc", "-1"]

    # Converts the supplied +Array+ to a +Hash+ to pass to mongo as
    # sorting parameters. The returned +Hash+ will vary depending 
    # on whether the passed +Array+ is one or two dimensional.
    #
    # Example:
    #
    # *DEPRECATED
    #
    # <tt>array_as_sort_parameters(["field1", "field2"])</tt> =>
    # <tt>{ "field1" => "1", "field2" => "1" }</tt>
    #
    # *New Syntax:
    #
    # <tt>array_as_sort_parameters([["field1", :asc], ["field2", :desc]])</tt> =>
    # <tt>{ "field1" => 1, "field2" => -1}</tt>
    def array_as_sort_parameters(value)
      warn_if_deprecated(value)
      order_by = OrderedHash.new
      value.each do |param|
        if (param.class.name == "String")
          order_by[param] = 1
        else
          order_by[param[0]] = sort_value(param[1]) unless param[1].nil?
        end
      end
      order_by
    end

    # Converts the supplied +String+ to a +Hash+ to pass to mongo as
    # a sorting parameter with ascending order. If the +String+
    # is empty then an empty +Hash+ will be returned.
    #
    # Example:
    #
    # *DEPRECATED
    #
    # <tt>string_as_sort_parameters("field")</tt> => <tt>{ "field" => 1 }</tt>
    # <tt>string_as_sort_parameters("")</tt> => <tt>{}</tt>
    def string_as_sort_parameters(value)
      warn_if_deprecated(value)
      return {} if value.empty?
      { value => 1 }
    end

    # Converts the supplied +Symbol+ to a +Hash+ to pass to mongo as
    # a sorting parameter with ascending order.
    #
    # Example:
    #
    # *DEPRECATED
    #
    # <tt>symbol_as_sort_parameters(:field)</tt> => <tt>{ "field" => 1 }</tt>
    def symbol_as_sort_parameters(value)
      warn_if_deprecated(value)
      { value.to_s => 1 }
    end

    # Converts the +String+, +Symbol+, or +Integer+ to the 
    # corresponding sort value in MongoDB.
    #
    # Valid conversions (case-insensitive):
    #
    # <tt>ascending, asc, :ascending, :asc, 1</tt> => <tt>1</tt>
    # <tt>descending, desc, :descending, :desc, -1</tt> => <tt>-1</tt>
    #
    # If the value is invalid then an error will be raised.
    def sort_value(value)
      val = value.to_s.downcase
      return 1 if ASCENDING.include?(val)
      return -1 if DESCENDING.include?(val)
      raise InvalidSortValueError.new(
        "#{self} was supplied as a sort direction when acceptable values are: " +
        "Mongo::ASCENDING, 'ascending', 'asc', :ascending, :asc, 1, Mongo::DESCENDING, 'descending', 'desc', :descending, :desc, -1.")
    end

    # This is the method to call when the client needs to be warned of
    # deprecation in the way sorting parameters are supplied.
    def warn_if_deprecated(value)
      unless value.is_a?(Array) && value.first.is_a?(Array)
        warn("Specifying sort order as #{value.inspect} has been deprecated in favor of a new syntax: \n" +
          "  :sort => [['field1', '(ascending|descending)'], ['field2', '(ascending|descending)']]")
      end
    end

  end
end
