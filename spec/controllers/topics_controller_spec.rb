require File.dirname(__FILE__) + '/../spec_helper'

describe TopicsController do
  integrate_views

  before(:each) do
    @topic = topics(:one)
  end
  
  it "should require login for new" do
    get :new
    response.should redirect_to(login_url)
  end
  
  # it "should have working pages" do
  #   login_as :quentin
  # 
  #   with_options :forum_id => forums(:one) do |page|
  #     page.get    :new
  #     page.get    :edit,    :id => @topic
  #     page.post   :create,  :topic => { :name => "The topic" }
  #     page.put    :update,  :id => @topic
  #     page.delete :destroy, :id => @topic
  #   end
  # end  
  
  it "should show a topic" do
    person = login_as(:quentin)
    put :show,  :id => @topic, :forum_id => @topic.forum
    response.should be_success
  end
  
  it "should support new topics" do
    person = login_as(:quentin)
    get :new, :forum_id => @topic.forum
    response.should be_success
  end
  
  it "should require login for create" do
    post :create, :topic => {:name => "The topic"}, :forum_id => forums(:one)
    response.should redirect_to(login_url)
  end
  
  it "should create new topics" do
    person = login_as(:quentin)
    Topic.should_receive(:new).with({"name" => "The topic"}).and_return(@topic)
    @topic.should_receive(:save).and_return(true)
    post :create, :topic => {:name => "The topic"}, :forum_id => forums(:one)
    response.should be_redirect
    flash[:success].should =~ /successfully created/
  end

  it "should associate a person to a topic" do
    person = login_as(:quentin)
    with_options :forum_id => forums(:one) do |page|
      page.post :create, :topic => { :name => "The topic" }
      assigns(:topic).person.should == person
    end
  end
    
  it "should fail gracefully when it cannot create new topics" do
    person = login_as(:quentin)
    Topic.should_receive(:new).with({"name" => "The topic"}).and_return(@topic)
    @topic.should_receive(:save).and_return(false)
    post :create, :topic => {:name => "The topic"}, :forum_id => forums(:one)
    response.should render_template(:new)
  end

  it "should require admin for edit" do
    person = login_as(:quentin)
    get :edit, :id => @topic, :forum_id => @topic.forum
    response.should redirect_to(home_url)
  end

  it "should support edited topics" do
    person = login_as(:admin)
    get :edit, :id => @topic, :forum_id => @topic.forum
    response.should be_success
  end

  it "should require admin for update" do
    person = login_as(:quentin)
    post :update, :id => @topic, :forum_id => @topic.forum
    # response.should redirect_to(login_url)
    response.should redirect_to(home_url)
  end

  it "should update edited topics" do
    person = login_as(:admin)
    Topic.stub!(:find).and_return(@topic)
    @topic.should_receive(:update_attributes).and_return(true)
    post :update, :id => @topic, :forum_id => forums(:one)
    response.should be_redirect
    flash[:success].should =~ /successfully updated/
  end

  it "should fail gracefully when it cannot update topics" do
    person = login_as(:admin)
    Topic.should_receive(:find).and_return(@topic)
    @topic.should_receive(:update_attributes).and_return(false)
    post :update, :id => @topic, :forum_id => forums(:one)
    response.should render_template(:edit)
  end
  
  it "should redirect properly on topic deletion" do
    person = login_as(:admin)
    @forum = Forum.find(@topic.forum)
    delete :destroy, :id => @topic, :forum_id => @forum
    response.should redirect_to(forum_url(@forum))
  end
  
  
end
