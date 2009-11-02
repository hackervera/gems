require 'test_helper'
require 'models'

class ManyDocumentsAsProxyTest < Test::Unit::TestCase
  def setup
    Post.collection.remove
    PostComment.collection.remove
  end

  should "default reader to empty array" do
    Post.new.comments.should == []
  end

  should "add type and id key to polymorphic class base" do
    PostComment.keys.keys.should include('commentable_type')
    PostComment.keys.keys.should include('commentable_id')
  end

  should "allow adding to association like it was an array" do
    post = Post.new
    post.comments << PostComment.new(:body => 'foo bar')
    post.comments << PostComment.new(:body => 'baz')
    post.comments.concat PostComment.new(:body => 'baz')

    post.comments.size.should == 3
  end

  should "be able to replace the association" do
    post = Post.new

    lambda {
      post.comments = [
        PostComment.new(:body => 'foo'),
        PostComment.new(:body => 'bar'),
        PostComment.new(:body => 'baz')
      ]
    }.should change { PostComment.count }.by(3)

    from_db = Post.find(post.id)
    from_db.comments.size.should == 3
    from_db.comments[0].body.should == 'foo'
    from_db.comments[1].body.should == 'bar'
    from_db.comments[2].body.should == 'baz'
  end

  context "build" do
    should "assign foreign key" do
      post = Post.new
      comment = post.comments.build
      comment.commentable_id.should == post.id
    end

    should "assign _type" do
      post = Post.new
      comment = post.comments.build
      comment.commentable_type.should == "Post"
    end

    should "allow assigning attributes" do
      post = Post.new
      comment = post.comments.build(:body => 'foo bar')
      comment.body.should == 'foo bar'
    end
  end

  context "create" do
    should "assign foreign key" do
      post = Post.new
      comment = post.comments.create
      comment.commentable_id.should == post.id
    end

    should "assign _type" do
      post = Post.new
      comment = post.comments.create
      comment.commentable_type.should == "Post"
    end

    should "save record" do
      post = Post.new
      lambda {
        post.comments.create(:body => 'baz')
      }.should change { PostComment.count }
    end

    should "allow passing attributes" do
      post = Post.create
      comment = post.comments.create(:body => 'foo bar')
      comment.body.should == 'foo bar'
    end
  end

  context "count" do
    should "work scoped to association" do
      post = Post.create
      3.times { post.comments.create(:body => 'foo bar') }

      other_post = Post.create
      2.times { other_post.comments.create(:body => 'baz') }

      post.comments.count.should == 3
      other_post.comments.count.should == 2
    end

    should "work with conditions" do
      post = Post.create
      post.comments.create(:body => 'foo bar')
      post.comments.create(:body => 'baz')
      post.comments.create(:body => 'foo bar')

      post.comments.count(:body => 'foo bar').should == 2
    end
  end

  context "Finding scoped to association" do
    setup do
      @post = Post.new

      @comment1 = PostComment.create(:body => 'comment1', :name => 'John')
      @comment2 = PostComment.create(:body => 'comment2', :name => 'Steve')
      @comment3 = PostComment.create(:body => 'comment3', :name => 'John')
      @post.comments = [@comment1, @comment2]
      @post.save

      @post2 = Post.create(:body => "post #2")
      @comment4 = PostComment.create(:body => 'comment1', :name => 'Chas')
      @comment5 = PostComment.create(:body => 'comment2', :name => 'Dan')
      @comment6 = PostComment.create(:body => 'comment3', :name => 'Ed')
      @post2.comments = [@comment4, @comment5, @comment6]
      @post2.save
    end

    context "with :all" do
      should "work" do
        @post.comments.find(:all).should include(@comment1)
        @post.comments.find(:all).should include(@comment2)
      end

      should "work with conditions" do
        comments = @post.comments.find(:all, :body => 'comment1')
        comments.should == [@comment1]
      end

      should "work with order" do
        comments = @post.comments.find(:all, :order => 'body desc')
        comments.should == [@comment2, @comment1]
      end
    end

    context "with #all" do
      should "work" do
        @post.comments.all.should include(@comment1)
        @post.comments.all.should include(@comment2)
      end

      should "work with conditions" do
        comments = @post.comments.all(:body => 'comment1')
        comments.should == [@comment1]
      end

      should "work with order" do
        comments = @post.comments.all(:order => 'body desc')
        comments.should == [@comment2, @comment1]
      end
    end

    context "with one id" do
      should "work for id in association" do
        @post.comments.find(@comment2.id).should == @comment2
      end

      should "not work for id not in association" do
        lambda {
          @post.comments.find(@comment5.id)
        }.should raise_error(MongoMapper::DocumentNotFound)
      end
    end

    context "with multiple ids" do
      should "work for ids in association" do
        posts = @post.comments.find(@comment1.id, @comment2.id)
        posts.should == [@comment1, @comment2]
      end

      should "not work for ids not in association" do
        lambda {
          @post.comments.find(@comment1.id, @comment2.id, @comment4.id)
        }.should raise_error(MongoMapper::DocumentNotFound)
      end
    end
    
    context "dynamic finders" do
      should "work with single key" do
        @post.comments.find_by_body('comment1').should == @comment1
        @post2.comments.find_by_body('comment1').should == @comment4
      end
      
      should "work with multiple keys" do
        @post.comments.find_by_body_and_name('comment1', 'John').should == @comment1
        @post.comments.find_by_body_and_name('comment1', 'Frank').should be_nil
      end
      
      should "raise error when using !" do
        lambda {
          @post.comments.find_by_body!('asdf')
        }.should raise_error(MongoMapper::DocumentNotFound)
      end
      
      context "find_or_create_by" do
        should "not create document if found" do
          lambda {
            comment = @post.comments.find_or_create_by_name('Steve')
            comment.commentable.should == @post
            comment.should == @comment2
          }.should_not change { PostComment.count }
        end

        should "create document if not found" do
          lambda {
            @post.comments.find_or_create_by_name('Chas')
          }.should change { PostComment.count }.by(1)
        end
      end
    end

    context "with #paginate" do
      setup do
        @comments = @post2.comments.paginate(:per_page => 2, :page => 1, :order => 'name')
      end

      should "return total pages" do
        @comments.total_pages.should == 2
      end

      should "return total entries" do
        @comments.total_entries.should == 3
      end

      should "return the subject" do
        @comments.should include(@comment4)
        @comments.should include(@comment5)
      end
    end
  end
end