require 'test_helper'

class TestRailsCompatibility < Test::Unit::TestCase
  class Item
    include MongoMapper::EmbeddedDocument
    key :for_all, String
  end
  
  class Order
    include MongoMapper::Document
    many :items, :class_name => 'TestRailsCompatibility::Item'
    key :order_only, String
  end
  
  context "Document" do
    setup do
      Order.collection.remove
    end

    should "alias new to new_record?" do
      instance = Order.new
      instance.new_record?.should == instance.new?
    end
  end
end