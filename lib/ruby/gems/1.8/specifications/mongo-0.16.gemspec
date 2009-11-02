# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mongo}
  s.version = "0.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jim Menard", "Mike Dirolf"]
  s.date = %q{2009-10-26}
  s.description = %q{A Ruby driver for MongoDB. For more information about Mongo, see http://www.mongodb.org.}
  s.email = %q{mongodb-dev@googlegroups.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "Rakefile", "mongo-ruby-driver.gemspec", "LICENSE.txt", "lib/mongo/admin.rb", "lib/mongo/collection.rb", "lib/mongo/connection.rb", "lib/mongo/constants.rb", "lib/mongo/cursor.rb", "lib/mongo/db.rb", "lib/mongo/errors.rb", "lib/mongo/gridfs/chunk.rb", "lib/mongo/gridfs/grid_store.rb", "lib/mongo/gridfs.rb", "lib/mongo/types/binary.rb", "lib/mongo/types/code.rb", "lib/mongo/types/dbref.rb", "lib/mongo/types/objectid.rb", "lib/mongo/types/regexp_of_holding.rb", "lib/mongo/util/bson.rb", "lib/mongo/util/byte_buffer.rb", "lib/mongo/util/conversions.rb", "lib/mongo/util/ordered_hash.rb", "lib/mongo/util/server_version.rb", "lib/mongo/util/support.rb", "lib/mongo/util/xml_to_ruby.rb", "lib/mongo.rb", "examples/admin.rb", "examples/benchmarks.rb", "examples/blog.rb", "examples/capped.rb", "examples/cursor.rb", "examples/gridfs.rb", "examples/index_test.rb", "examples/info.rb", "examples/queries.rb", "examples/simple.rb", "examples/strict.rb", "examples/types.rb", "bin/autoreconnect.rb", "bin/bson_benchmark.rb", "bin/fail_if_no_c.rb", "test/mongo-qa/_common.rb", "test/test_admin.rb", "test/test_bson.rb", "test/test_byte_buffer.rb", "test/test_chunk.rb", "test/test_collection.rb", "test/test_connection.rb", "test/test_conversions.rb", "test/test_cursor.rb", "test/test_db.rb", "test/test_db_api.rb", "test/test_db_connection.rb", "test/test_grid_store.rb", "test/test_helper.rb", "test/test_objectid.rb", "test/test_ordered_hash.rb", "test/test_round_trip.rb", "test/test_slave_connection.rb", "test/test_threading.rb", "test/unit/cursor_test.rb"]
  s.homepage = %q{http://www.mongodb.org}
  s.rdoc_options = ["--main", "README.rdoc", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Ruby driver for the MongoDB}
  s.test_files = ["test/mongo-qa/_common.rb", "test/test_admin.rb", "test/test_bson.rb", "test/test_byte_buffer.rb", "test/test_chunk.rb", "test/test_collection.rb", "test/test_connection.rb", "test/test_conversions.rb", "test/test_cursor.rb", "test/test_db.rb", "test/test_db_api.rb", "test/test_db_connection.rb", "test/test_grid_store.rb", "test/test_helper.rb", "test/test_objectid.rb", "test/test_ordered_hash.rb", "test/test_round_trip.rb", "test/test_slave_connection.rb", "test/test_threading.rb", "test/unit/cursor_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
