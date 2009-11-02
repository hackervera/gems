require 'active_support'
require 'mongo'
require 'validatable'

module MongoMapper
  # generic MM error
  class MongoMapperError < StandardError; end
  
  # raised when key expected to exist but not found
  class KeyNotFound < MongoMapperError; end
  
  # raised when document expected but not found
  class DocumentNotFound < MongoMapperError; end
  
  # raised when document not valid and using !
  class DocumentNotValid < MongoMapperError
    def initialize(document)
      @document = document
      super("Validation failed: #{@document.errors.full_messages.join(", ")}")
    end
  end
  
  def self.connection
    @@connection ||= Mongo::Connection.new
  end

  def self.connection=(new_connection)
    @@connection = new_connection
  end
  
  def self.logger
    connection.logger
  end

  def self.database=(name)
    @@database = nil
    @@database_name = name
  end

  def self.database
    if @@database_name.blank?
      raise 'You forgot to set the default database name: MongoMapper.database = "foobar"'
    end
    
    @@database ||= MongoMapper.connection.db(@@database_name)
  end
  
  def self.ensured_indexes
    @@ensured_indexes ||= []
  end
  
  def self.ensure_index(klass, keys, options={})
    ensured_indexes << {:klass => klass, :keys => keys, :options => options}
  end
  
  def self.ensure_indexes!
    ensured_indexes.each do |index|
      unique = index[:options].delete(:unique)
      index[:klass].collection.create_index(index[:keys], unique)
    end
  end
  
  module Finders
    def dynamic_find(finder, args)
      attributes = {}
      finder.attributes.each_with_index do |attr, index|
        attributes[attr] = args[index]
      end
      
      options = args.extract_options!.merge(attributes)
      result  = find(finder.finder, options)

      if result.nil?
        if finder.bang
          raise DocumentNotFound, "Couldn't find Document with #{attributes.inspect} in collection named #{collection.name}"
        end

        if finder.instantiator
          self.send(finder.instantiator, attributes)
        end
      else
        result
      end
    end
  end
end

require 'mongo_mapper/support'
require 'mongo_mapper/associations'
require 'mongo_mapper/associations/base'
require 'mongo_mapper/associations/proxy'
require 'mongo_mapper/associations/many_documents_proxy'
require 'mongo_mapper/associations/belongs_to_proxy'
require 'mongo_mapper/associations/belongs_to_polymorphic_proxy'
require 'mongo_mapper/associations/many_proxy'
require 'mongo_mapper/associations/many_polymorphic_proxy'
require 'mongo_mapper/associations/many_embedded_proxy'
require 'mongo_mapper/associations/many_embedded_polymorphic_proxy'
require 'mongo_mapper/associations/many_documents_as_proxy'
require 'mongo_mapper/callbacks'
require 'mongo_mapper/finder_options'
require 'mongo_mapper/dirty'
require 'mongo_mapper/dynamic_finder'
require 'mongo_mapper/key'
require 'mongo_mapper/observing'
require 'mongo_mapper/pagination'
require 'mongo_mapper/serialization'
require 'mongo_mapper/validations'
require 'mongo_mapper/rails_compatibility/document'
require 'mongo_mapper/rails_compatibility/embedded_document'
require 'mongo_mapper/embedded_document'
require 'mongo_mapper/document'
