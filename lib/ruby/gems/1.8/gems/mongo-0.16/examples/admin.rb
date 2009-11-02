$LOAD_PATH[0,0] = File.join(File.dirname(__FILE__), '..', 'lib')
require 'mongo'
require 'pp'

include Mongo

host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = Connection.new(host, port).db('ruby-mongo-examples')
coll = db.create_collection('test')

# Erase all records from collection, if any
coll.clear

admin = db.admin

# Profiling level set/get
p admin.profiling_level

# Start profiling everything
admin.profiling_level = :all

# Read records, creating a profiling event
coll.find().to_a

# Stop profiling
admin.profiling_level = :off

# Print all profiling info
pp admin.profiling_info

# Validate returns a hash if all is well or raises an exception if there is a
# problem.
info = admin.validate_collection(coll.name)
puts "valid = #{info['ok']}"
puts info['result']

# Destroy the collection
coll.drop
