$LOAD_PATH[0,0] = File.join(File.dirname(__FILE__), '..', 'lib')
require 'mongo'

include Mongo

host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = Connection.new(host, port).db('ruby-mongo-examples')
coll = db.collection('test')

# Erase all records from collection, if any
coll.clear

# Insert 3 records
3.times { |i| coll.insert({'a' => i+1}) }

# Collection names in database
p db.collection_names

# More information about each collection
p db.collections_info

# Index information
db.create_index('test', 'a')
p db.index_information('test')

# Destroy the collection
coll.drop
