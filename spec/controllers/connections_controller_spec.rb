require File.dirname(__FILE__) + '/../spec_helper'

describe ConnectionsController do
  integrate_views
  
  before(:each) do
    @person  = login_as(:quentin)
    @contact = people(:aaron)
  end

  it "should get the index page for authorized users" do
    get :index, :person_id => @person
    response.should be_success
  end
  
  it "should not get the index page for unauthorized users" do
    get :index, :person_id => @contact
    response.should redirect_to(home_url)
  end
  
  it "should get a meaningless show page" do
    get :show, :id => @connection
    response.body.should == ''
  end
  
  it "should protect the create page" do
    logout
    post :create
    response.should redirect_to(login_url)
  end
  
  it "should create a new connection request" do
    Connection.should_receive(:request).with(@person, @contact).
      and_return(true)
    post :create, :person_id => @contact
    response.should redirect_to(home_url)
  end
  
  it "should fail gracefully when a new connection request cannot be created" do
    Connection.should_receive(:request).with(@person, @contact).
      and_return(nil)
    post :create, :person_id => @contact
    response.should redirect_to(home_url)
  end
  
  describe "with existing connection" do
    integrate_views
    
    before(:each) do
      Connection.request(@person, @contact)
      @connection = Connection.conn(@person, @contact)
    end
        
    it "should get the edit page" do
      get :edit, :id => @connection
      response.should be_success
    end
    
    it "should require the right current person" do
      login_as :aaron
      get :edit, :id => @connection
      response.should redirect_to(home_url)
    end

    it "should fail when the connection is invalid" do
      Connection.should_receive(:find).and_raise(ActiveRecord::RecordNotFound)
      get :edit, :id => @connection
    end
    
    it "should accept the connection" do
      put :update, :id => @connection, :commit => "Accept"
      Connection.find(@connection).status.should == Connection::ACCEPTED
      response.should redirect_to(home_url)
    end
    
    it "should decline the connection" do
      put :update, :id => @connection, :commit => "Decline"
      @connection.should_not exist_in_database
      response.should redirect_to(home_url)
    end
  
    it "should end a connection" do
      delete :destroy, :id => @connection
      response.should redirect_to(person_connections_url(@person))
    end
    
    it "should redirect if the target person is inactive" do
      @contact.deactivated = true
      put :update, :id => @connection, :commit => "Accept"
      response.should redirect_to(home_url)
    end
    
    it "should flash an error if the target is inactive" do
      @deactivated = people(:deactivated)
      Connection.request(@person, @deactivated)
      @bad_connection = Connection.conn(@person, @deactivated)

      get :update, :id => @bad_connection, :commit => "Accept"
      flash[:error].should == "Invalid connection request: person deactivated"
    end
  end  
end
