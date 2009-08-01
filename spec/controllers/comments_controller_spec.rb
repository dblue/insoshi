require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  
  describe "blog comments" do
    integrate_views
  
    before(:each) do
      @commenter = login_as(:aaron)
      @blog   = people(:quentin).blog
      @post   = posts(:blog_post)
      @comment = comments(:blog_comment)
    end

    it "should respond to index by redirecting to a blog post url" do
      get :index, :blog_id => @blog, :post_id => @post
      response.should redirect_to(blog_post_url(@blog, @post))
    end

    it "should respond to show by redirecting to a blog post url" do
      get :show, :blog_id => @blog, :post_id => @post, :comment_id => @comment
      response.should redirect_to(blog_post_url(@blog, @post))
    end
      
    it "should have working pages" do
      with_options :blog_id => @blog, :post_id => @post do |page|
        page.get    :new
        page.post   :create,  :comment => { }
        page.delete :destroy, :id => comments(:blog_comment)
      end
    end
    
    it "should create a blog comment" do
      lambda do
        post :create, :blog_id => @blog, :post_id => @post,
                      :comment => { :body => "The body" }
        response.should redirect_to(blog_post_url(@blog, @post))
      end.should change(Comment, :count).by(1)
    end
    
    it "should create the right blog comment associations" do
      lambda do
        post :create, :blog_id => @blog, :post_id => @post,
                      :post => { :body => "The body" }
        assigns(:comment).commenter.should == @commenter
        assigns(:comment).post.should == @post
      end 
    end
    
    it "should render the new template on creation failure" do
      post :create, :blog_id => @blog, :post_id => @post, :comment => {}
      response.should render_template("blog_post_new")
    end
    
    it "should associate a commenter to the comment" do
      post :create, :blog_id => @blog, :post_id => @post,
                    :comment => { :body => "The body" }
      assigns(:comment).commenter.should == @commenter
    end
    
    it "should allow destroy" do
      login_as @blog.person
      comment = comments(:blog_comment)
      delete :destroy, :blog_id => @blog, :post_id => @post, :id => comment
      comment.should_not exist_in_database
    end
    
    it "should require the correct user to destroy a comment" do
      login_as @commenter
      comment = comments(:blog_comment)
      delete :destroy, :blog_id => @blog, :post_id => @post, :id => comment
      response.should redirect_to(home_url)
    end
  end

  
  describe "wall comments" do
    integrate_views
  
    before(:each) do
      @commenter = login_as(:aaron)
      @person    = people(:quentin)
      Connection.connect(@person, @commenter)
      @comment   = comments(:wall_comment)
    end
  
    it "should respond to index by redirecting" do
      get :index, :person_id => @person
      response.should redirect_to((person_url @person)+'#tWall')
    end

    it "should respond to show by redirecting" do
      get :show, :person_id => @person, :comment_id => @comment
      response.should redirect_to((person_url @person)+'#tWall')
    end
  
    it "should have working pages" do
      with_options :person_id => @person do |page|
        page.get    :new
        page.post   :create,  :comment => { }
        page.delete :destroy, :id => comments(:wall_comment)
      end
    end
  
    it "should reject comments from an unconnected commenter" do
      @bad_commenter = login_as(:kelly)
      post :create, :person_id => @person,
                    :comment => { :body => "The body" }
      response.should redirect_to(person_url(@person))
      flash[:notice].should == "You must be contacts to complete that action"
    end
    
    it "should allow create" do
      lambda do
        post :create, :person_id => @person,
                      :comment => { :body => "The body" }
        #should go directly to the person's wall              
        response.should redirect_to(person_url(@person)+'#tWall')
      end.should change(Comment, :count).by(1)
    end
      
    it "should associate a person to a comment" do
      with_options :person_id => @person do |page|
        page.post :create, :comment => { :body => "The body" }
        assigns(:comment).commenter.should == @commenter
        assigns(:comment).commentable.should == @person
      end
    end
    
    it "should render the new template on creation failure" do
      post :create, :person_id => @person, :comment => { :body => "" }
      response.should render_template("wall_new")
    end
    
    it "should allow destroy for person" do
      login_as @person
      comment = comments(:wall_comment)
      delete :destroy, :person_id => @person, :id => comment
      comment.should_not exist_in_database
    end
    
    it "should allow destroy for commenter" do
      comment = comments(:wall_comment)
      login_as comment.commenter
      delete :destroy, :person_id => @person, :id => comment
      comment.should_not exist_in_database
    end
    
    it "should protect the destroy action" do
      login_as :kelly
      comment = comments(:wall_comment)
      delete :destroy, :person_id => @person, :id => comment
      response.should redirect_to(home_url)
    end
  end

  describe "event comments" do
    integrate_views
  
    before(:each) do
      @commenter = login_as(:quentin)
      @person    = people(:aaron)
      @event     = events(:public)
    end

    it "should respond to index by redirecting to an event url" do
      get :index, :event_id => @event
      response.should redirect_to(event_url(@event))
    end

    it "should respond to show" do
      get :show, :event_id => @event
      response.should redirect_to(event_url(@event))
    end
      
    it "should have working pages" do
      with_options :event_id => @event do |page|
        page.get    :new
        page.post   :create,  :comment => { }
        page.delete :destroy, :id => comments(:event_comment)
      end
    end
    
    it "should create an event comment" do
      lambda do
        post :create, :event_id => @event,
                      :comment => { :body => "The body" }
        response.should redirect_to(event_url(@event))
      end.should change(Comment, :count).by(1)
    end
    
    it "should associate the comment with the event" do
      lambda do
        post :create, :event_id => @event,
                      :post => { :body => "The body" }
        assigns(:comment).commenter.should == @commenter
        assigns(:comment).event.should == @event
      end 
    end
    
    it "should associate a commenter to the comment" do
      post :create, :event_id => @event,
                    :comment => { :body => "The body" }
      assigns(:comment).commenter.should == @commenter
    end

    it "should render the new template on creation failure" do
      post :create, :event_id => @event, :comment => {}
      response.should render_template("event_new")
    end    
    
    it "should allow destroy" do
      login_as @event.person
      comment = comments(:event_comment)
      delete :destroy, :event_id => @event, :id => comment
      comment.should_not exist_in_database
    end
    
    it "should require the correct user to destroy a comment" do
      login_as @commenter
      comment = comments(:event_comment)
      delete :destroy, :event_id => @event, :id => comment
      response.should redirect_to(home_url)
    end
  end
end
