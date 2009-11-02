require 'test_helper'
require 'models'

class ManyProxyTest < Test::Unit::TestCase
  def setup
    Project.collection.remove
    Status.collection.remove
  end
  
  should "default reader to empty array" do
    project = Project.new
    project.statuses.should == []
  end

  should "allow adding to association like it was an array" do
    project = Project.new
    project.statuses <<     Status.new(:name => 'Foo1!')
    project.statuses.push   Status.new(:name => 'Foo2!')
    project.statuses.concat Status.new(:name => 'Foo3!')
    project.statuses.size.should == 3
  end

  should "be able to replace the association" do
    project = Project.new
    project.statuses = [Status.new("name" => "ready")]
    project.save.should be_true

    from_db = Project.find(project.id)
    from_db.statuses.size.should == 1
    from_db.statuses[0].name.should == "ready"
  end
  
  should "correctly assign foreign key when using <<, push and concat" do
    project = Project.new
    project.statuses <<     Status.new(:name => '<<')
    project.statuses.push   Status.new(:name => 'push')
    project.statuses.concat Status.new(:name => 'concat')
    
    from_db = Project.find(project.id)
    from_db.statuses[0].project_id.should == project.id
    from_db.statuses[1].project_id.should == project.id
    from_db.statuses[2].project_id.should == project.id
  end
  
  context "build" do
    should "assign foreign key" do
      project = Project.create
      status = project.statuses.build
      status.project_id.should == project.id
    end

    should "allow assigning attributes" do
      project = Project.create
      status = project.statuses.build(:name => 'Foo')
      status.name.should == 'Foo'
    end
  end
  
  context "create" do
    should "assign foreign key" do
      project = Project.create
      status = project.statuses.create(:name => 'Foo!')
      status.project_id.should == project.id
    end
    
    should "save record" do
      project = Project.create
      lambda {
        project.statuses.create(:name => 'Foo!')
      }.should change { Status.count }
    end
    
    should "allow passing attributes" do
      project = Project.create
      status = project.statuses.create(:name => 'Foo!')
      status.name.should == 'Foo!'
    end
  end
  
  context "create!" do
    should "assign foreign key" do
      project = Project.create
      status = project.statuses.create!(:name => 'Foo!')
      status.project_id.should == project.id
    end
    
    should "save record" do
      project = Project.create
      lambda {
        project.statuses.create!(:name => 'Foo!')
      }.should change { Status.count }
    end
    
    should "allow passing attributes" do
      project = Project.create
      status = project.statuses.create!(:name => 'Foo!')
      status.name.should == 'Foo!'
    end
    
    should "raise exception if not valid" do
      project = Project.create
      lambda {
        project.statuses.create!(:name => nil)
      }.should raise_error(MongoMapper::DocumentNotValid)
    end
  end
  
  
  context "count" do
    should "work scoped to association" do
      project = Project.create
      3.times { project.statuses.create(:name => 'Foo!') }
      
      other_project = Project.create
      2.times { other_project.statuses.create(:name => 'Foo!') }
      
      project.statuses.count.should == 3
      other_project.statuses.count.should == 2
    end
    
    should "work with conditions" do
      project = Project.create
      project.statuses.create(:name => 'Foo')
      project.statuses.create(:name => 'Other 1')
      project.statuses.create(:name => 'Other 2')
      
      project.statuses.count(:name => 'Foo').should == 1
    end
  end
  
  context "Unassociating documents" do
    setup do
      @project = Project.create
      @project.statuses << Status.create(:name => '1')
      @project.statuses << Status.create(:name => '2')

      @project2 = Project.create
      @project2.statuses << Status.create(:name => '1')
      @project2.statuses << Status.create(:name => '2')
    end

    should "work with destroy all" do
      @project.statuses.count.should == 2
      @project.statuses.destroy_all
      @project.statuses.count.should == 0

      @project2.statuses.count.should == 2
      Status.count.should == 2
    end
    
    should "work with destroy all and conditions" do
      @project.statuses.count.should == 2
      @project.statuses.destroy_all(:name => '1')
      @project.statuses.count.should == 1

      @project2.statuses.count.should == 2
      Status.count.should == 3
    end
    
    should "work with delete all" do
      @project.statuses.count.should == 2
      @project.statuses.delete_all
      @project.statuses.count.should == 0
      
      @project2.statuses.count.should == 2
      Status.count.should == 2
    end
    
    should "work with delete all and conditions" do
      @project.statuses.count.should == 2
      @project.statuses.delete_all(:name => '1')
      @project.statuses.count.should == 1
      
      @project2.statuses.count.should == 2
      Status.count.should == 3
    end
    
    should "work with nullify" do
      @project.statuses.count.should == 2
      @project.statuses.nullify
      @project.statuses.count.should == 0
      
      @project2.statuses.count.should == 2
      Status.count.should == 4
      Status.count(:name => '1').should == 2
      Status.count(:name => '2').should == 2
    end
  end  
  
  context "Finding scoped to association" do
    setup do
      @project1          = Project.new(:name => 'Project 1')
      @brand_new         = Status.create(:name => 'New', :position => 1 )
      @complete          = Status.create(:name => 'Complete', :position => 2)
      @project1.statuses = [@brand_new, @complete]
      @project1.save
      
      @project2          = Project.create(:name => 'Project 2')
      @in_progress       = Status.create(:name => 'In Progress')
      @archived          = Status.create(:name => 'Archived')
      @another_complete  = Status.create(:name => 'Complete')
      @project2.statuses = [@in_progress, @archived, @another_complete]
      @project2.save
    end
    
    context "dynamic finders" do
      should "work with single key" do
        @project1.statuses.find_by_name('New').should == @brand_new
        @project2.statuses.find_by_name('In Progress').should == @in_progress
      end
      
      should "work with multiple keys" do
        @project1.statuses.find_by_name_and_position('New', 1).should == @brand_new
        @project1.statuses.find_by_name_and_position('New', 2).should be_nil
      end
      
      should "raise error when using !" do
        lambda {
          @project1.statuses.find_by_name!('Fake')
        }.should raise_error(MongoMapper::DocumentNotFound)
      end
      
      context "find_or_create_by" do
        should "not create document if found" do
          lambda {
            status = @project1.statuses.find_or_create_by_name('New')
            status.project.should == @project1
            status.should == @brand_new
          }.should_not change { Status.count }
        end

        should "create document if not found" do
          lambda {
            status = @project1.statuses.find_or_create_by_name('Delivered')
            status.project.should == @project1
          }.should change { Status.count }.by(1)
        end
      end
    end
    
    context "with :all" do
      should "work" do
        @project1.statuses.find(:all, :order => "position asc").should == [@brand_new, @complete]
      end
      
      should "work with conditions" do
        statuses = @project1.statuses.find(:all, :name => 'Complete')
        statuses.should == [@complete]
      end
      
      should "work with order" do
        statuses = @project1.statuses.find(:all, :order => 'name asc')
        statuses.should == [@complete, @brand_new]
      end
    end

    context "with #all" do
      should "work" do
        @project1.statuses.all(:order => "position asc").should == [@brand_new, @complete]
      end
      
      should "work with conditions" do
        statuses = @project1.statuses.all(:name => 'Complete')
        statuses.should == [@complete]
      end
      
      should "work with order" do
        statuses = @project1.statuses.all(:order => 'name asc')
        statuses.should == [@complete, @brand_new]
      end
    end
    
    context "with :first" do
      should "work" do
        @project1.statuses.find(:first, :order => 'name').should == @complete
      end
      
      should "work with conditions" do
        status = @project1.statuses.find(:first, :name => 'Complete')
        status.should == @complete
      end
    end
    
    context "with #first" do
      should "work" do
        @project1.statuses.first(:order => 'name').should == @complete
      end
      
      should "work with conditions" do
        status = @project1.statuses.first(:name => 'Complete')
        status.should == @complete
      end
    end
    
    context "with :last" do
      should "work" do
        @project1.statuses.find(:last, :order => "position asc").should == @complete
      end
      
      should "work with conditions" do
        status = @project1.statuses.find(:last, :order => 'position', :name => 'New')
        status.should == @brand_new
      end
    end
    
    context "with #last" do
      should "work" do
        @project1.statuses.last(:order => "position asc").should == @complete
      end
      
      should "work with conditions" do
        status = @project1.statuses.last(:order => 'position', :name => 'New')
        status.should == @brand_new
      end
    end
    
    context "with one id" do
      should "work for id in association" do
        @project1.statuses.find(@complete.id).should == @complete
      end
      
      should "not work for id not in association" do
        lambda {
          @project1.statuses.find(@archived.id)
        }.should raise_error(MongoMapper::DocumentNotFound)
      end
    end
    
    context "with multiple ids" do
      should "work for ids in association" do
        statuses = @project1.statuses.find(@brand_new.id, @complete.id)
        statuses.should == [@brand_new, @complete]
      end
      
      should "not work for ids not in association" do
        lambda {
          @project1.statuses.find(@brand_new.id, @complete.id, @archived.id)
        }.should raise_error(MongoMapper::DocumentNotFound)
      end
    end
    
    context "with #paginate" do
      setup do
        @statuses = @project2.statuses.paginate(:per_page => 2, :page => 1, :order => 'name asc')
      end
      
      should "return total pages" do
        @statuses.total_pages.should == 2
      end
      
      should "return total entries" do
        @statuses.total_entries.should == 3
      end
      
      should "return the subject" do
        @statuses.collect(&:name).should == %w(Archived Complete)
      end
    end
  end

  context "extending the association" do
    should "work using a block passed to many" do
      project = Project.new(:name => "Some Project")
      status1 = Status.new(:name => "New")
      status2 = Status.new(:name => "Assigned")
      status3 = Status.new(:name => "Closed")
      project.statuses = [status1, status2, status3]
      project.save
      project.statuses.open.should == [status1, status2]
    end
  
    should "work using many's :extend option" do
      project = Project.new(:name => "Some Project")
      collaborator1 = Collaborator.new(:name => "zing")
      collaborator2 = Collaborator.new(:name => "zang")
      project.collaborators = [collaborator1, collaborator2]
      project.save
      project.collaborators.top.should == collaborator1
    end
  end
end
