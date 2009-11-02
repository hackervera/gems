require 'test_helper'
require 'models'

class ManyEmbeddedProxyTest < Test::Unit::TestCase
  def setup
    Project.collection.remove
    RealPerson.collection.remove
  end
    
  should "default reader to empty array" do
    Project.new.addresses.should == []
  end
  
  should "allow adding to association like it was an array" do
    project = Project.new
    project.addresses << Address.new
    project.addresses.push Address.new
    project.addresses.size.should == 2
  end
  
  should "allow finding :all embedded documents" do
    project = Project.new
    project.addresses << Address.new
    project.addresses << Address.new
    project.save
  end

  should "be embedded in document on save" do
    sb = Address.new(:city => 'South Bend', :state => 'IN')
    chi = Address.new(:city => 'Chicago', :state => 'IL')
    project = Project.new
    project.addresses << sb
    project.addresses << chi
    project.save

    from_db = Project.find(project.id)
    from_db.addresses.size.should == 2
    from_db.addresses[0].should == sb
    from_db.addresses[1].should == chi
  end
  
  should "allow embedding arbitrarily deep" do
    @document = Class.new do
      include MongoMapper::Document
      set_collection_name 'test'
      key :person, Person
    end
    @document.collection.remove
    
    meg = Person.new(:name => "Meg")
    meg.child = Person.new(:name => "Steve")
    meg.child.child = Person.new(:name => "Linda")
    
    doc = @document.new(:person => meg)
    doc.save
    
    from_db = @document.find(doc.id)
    from_db.person.name.should == 'Meg'
    from_db.person.child.name.should == 'Steve'
    from_db.person.child.child.name.should == 'Linda'
  end
  
  should "allow assignment of 'many' embedded documents using a hash" do
    person_attributes = { 
      "name" => "Mr. Pet Lover", 
      "pets" => [
        {"name" => "Jimmy", "species" => "Cocker Spainel"},
        {"name" => "Sasha", "species" => "Siberian Husky"}, 
      ] 
    }
    
    pet_lover = RealPerson.new(person_attributes)
    pet_lover.name.should == "Mr. Pet Lover"
    pet_lover.pets[0].name.should == "Jimmy"
    pet_lover.pets[0].species.should == "Cocker Spainel"
    pet_lover.pets[1].name.should == "Sasha"
    pet_lover.pets[1].species.should == "Siberian Husky"
    pet_lover.save.should be_true
    
    from_db = RealPerson.find(pet_lover.id)
    from_db.name.should == "Mr. Pet Lover"
    from_db.pets[0].name.should == "Jimmy"
    from_db.pets[0].species.should == "Cocker Spainel"
    from_db.pets[1].name.should == "Sasha"
    from_db.pets[1].species.should == "Siberian Husky"
  end

  context "embedding many embedded documents" do
    setup do
      @document = Class.new do
        include MongoMapper::Document
        set_collection_name 'test'
        many :people
      end
      @document.collection.remove
    end

    should "persist all embedded documents" do
      meg = Person.new(:name => "Meg")
      sparky = Pet.new(:name => "Sparky", :species => "Dog")
      koda = Pet.new(:name => "Koda", :species => "Dog")

      doc = @document.new

      meg.pets << sparky
      meg.pets << koda

      doc.people << meg
      doc.save

      from_db = @document.find(doc.id)
      from_db.people.first.name.should == "Meg"
      from_db.people.first.pets.should_not == []
      from_db.people.first.pets.first.name.should == "Sparky"
      from_db.people.first.pets.first.species.should == "Dog"
      from_db.people.first.pets[1].name.should == "Koda"
      from_db.people.first.pets[1].species.should == "Dog"
    end

    should "create a reference to the root document for all embedded documents before save" do
      meg = Person.new(:name => "Meg")
      sparky = Pet.new(:name => "Sparky", :species => "Dog")

      doc = @document.new

      doc.people << meg
      meg.pets << sparky

      doc.people.first._root_document.should == doc
      doc.people.first.pets.first._root_document.should == doc
    end

    should "create properly-named reference to parent document when building off association proxy" do
      person = RealPerson.new
      pet = person.pets.build
      person.should == pet.real_person
    end


    should "create a reference to the root document for all embedded documents" do
      meg = Person.new(:name => "Meg")
      sparky = Pet.new(:name => "Sparky", :species => "Dog")

      doc = @document.new

      meg.pets << sparky

      doc.people << meg
      doc.save

      from_db = @document.find(doc.id)
      from_db.people.first._root_document.should == doc
      from_db.people.first.pets.first._root_document.should == doc
    end
  end
  
  should "allow retrieval via find(:all)" do
    meg = Person.new(:name => "Meg")
    sparky = Pet.new(:name => "Sparky", :species => "Dog")

    meg.pets << sparky
    
    meg.pets.find(:all).should include(sparky)
  end
  
  should "allow retrieval via find(id)" do
    meg = Person.new(:name => "Meg")
    sparky = Pet.new(:name => "Sparky", :species => "Dog")

    meg.pets << sparky
    
    meg.pets.find(sparky.id).should == sparky
  end
  
  context "extending the association" do
    should "work using a block passed to many" do
      project = Project.new(:name => "Some Project")
      addr1 = Address.new(:address => "Gate-3 Lankershim Blvd.", :city => "Universal City", :state => "CA", :zip => "91608")
      addr2 = Address.new(:address => "3000 W. Alameda Ave.", :city => "Burbank", :state => "CA", :zip => "91523")
      addr3 = Address.new(:address => "111 Some Ln", :city => "Nashville", :state => "TN", :zip => "37211")
      project.addresses = [addr1, addr2, addr3]
      project.save
      project.addresses.find_all_by_state("CA").should == [addr1, addr2]
    end
  
    should "work using many's :extend option" do
      project = Project.new(:name => "Some Project")
      person1 = Person.new(:name => "Steve")
      person2 = Person.new(:name => "Betty")
      person3 = Person.new(:name => "Cynthia")

      project.people << person1
      project.people << person2
      project.people << person3
      project.save
      project.people.find_by_name("Steve").should == person1
    end
  end
end