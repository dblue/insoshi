require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ForumsController do
  it "should restrict forum modifications to admins" do
    not_admin = login_as(:aaron)
    get :new
    response.should redirect_to(home_url)
  end
  
  describe "with an admin" do
    before(:each) do
      login_as(:admin)
      @forum = Forum.find(:first)
    end
    
    it "should respond to index" do
      get :index
      response.should be_success
    end    

    it "should allow admin to access a modification page" do
      get :new
      response.should be_success    
    end
  
    it "should respond to show" do
      get :show, :id => @forum
      response.should be_success
    end
    
    it "should respond to edit" do
      get :edit, :id => @forum
      response.should be_success
    end

    it "should respond to create" do
      Forum.stub!(:new).and_return(@forum)
      @forum.stub!(:save).and_return(true)
      post :create
      response.should redirect_to(admin_forums_path)
    end
    
    it "should respond properly to failed creates" do
      Forum.stub!(:new).and_return(@forum)
      @forum.stub!(:save).and_return(false)
      post :create
      response.should render_template(:new)
    end    
    
    it "should respond to update" do
      Forum.stub!(:find).and_return(@forum)
      @forum.stub!(:save).and_return(true)
      post :update, :id => @forum
      response.should redirect_to(admin_forums_path)
    end
    
    it "should respond properly to failed updates" do
      Forum.stub!(:find).and_return(@forum)
      @forum.stub!(:save).and_return(false)
      post :update, :id => @forum
      response.should render_template(:edit)
    end  
    
    it "should protect the last forum" do
      Forum.stub!(:count).and_return(1)
      post :destroy, :id => @forum
      response.should redirect_to(admin_forums_url)
    end

    it "should set an error in flash" do
      Forum.stub!(:count).and_return(1)
      post :destroy, :id => @forum
      flash[:error].should == "There must be at least one forum."
    end
    
    it "should respond to destroy if there is more than one forum" do
      Forum.stub!(:count).and_return(2)
      Forum.stub!(:find).and_return(@forum)
      @forum.stub!(:destroy).and_return(true)
      post :destroy, :id => @forum
      response.should redirect_to(admin_forums_url)
    end
    
  end
  
end
