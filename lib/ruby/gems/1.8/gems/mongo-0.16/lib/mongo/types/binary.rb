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

require 'mongo/util/byte_buffer'

module Mongo

  # An array of binary bytes with a Mongo subtype value.
  class Binary < ByteBuffer

    SUBTYPE_BYTES = 0x02
    SUBTYPE_UUID = 0x03
    SUBTYPE_MD5 = 0x05
    SUBTYPE_USER_DEFINED = 0x80

    # One of the SUBTYPE_* constants. Default is SUBTYPE_BYTES.
    attr_accessor :subtype

    def initialize(initial_data=[], subtype=SUBTYPE_BYTES)
      super(initial_data)
      @subtype = subtype
    end

  end
end
