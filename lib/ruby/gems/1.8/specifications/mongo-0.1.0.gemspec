# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mongo}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jim Menard"]
  s.date = %q{2009-01-15}
  s.default_executable = %q{mongo_console}
  s.description = %q{This is a simple pure-Ruby driver for the 10gen Mongo DB. For more information about Mongo, see http://www.mongodb.org.}
  s.email = %q{jimm@io.com}
  s.executables = ["mongo_console"]
  s.files = ["bin/mongo_console", "bin/validate", "lib/mongo/admin.rb", "lib/mongo/collection.rb", "lib/mongo/cursor.rb", "lib/mongo/db.rb", "lib/mongo/message/get_more_message.rb", "lib/mongo/message/insert_message.rb", "lib/mongo/message/kill_cursors_message.rb", "lib/mongo/message/message.rb", "lib/mongo/message/message_header.rb", "lib/mongo/message/msg_message.rb", "lib/mongo/message/opcodes.rb", "lib/mongo/message/query_message.rb", "lib/mongo/message/remove_message.rb", "lib/mongo/message/update_message.rb", "lib/mongo/message.rb", "lib/mongo/mongo.rb", "lib/mongo/query.rb", "lib/mongo/types/binary.rb", "lib/mongo/types/dbref.rb", "lib/mongo/types/objectid.rb", "lib/mongo/types/regexp_of_holding.rb", "lib/mongo/types/undefined.rb", "lib/mongo/util/bson.rb", "lib/mongo/util/byte_buffer.rb", "lib/mongo/util/ordered_hash.rb", "lib/mongo/util/xml_to_ruby.rb", "lib/mongo.rb", "tests/test_admin.rb", "tests/test_bson.rb", "tests/test_byte_buffer.rb", "tests/test_cursor.rb", "tests/test_db.rb", "tests/test_db_api.rb", "tests/test_db_connection.rb", "tests/test_message.rb", "tests/test_objectid.rb", "tests/test_ordered_hash.rb", "tests/test_round_trip.rb", "Rakefile", "README.rdoc"]
  s.homepage = %q{http://www.mongodb.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mongo}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Simple pure-Ruby driver for the 10gen Mongo DB}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
