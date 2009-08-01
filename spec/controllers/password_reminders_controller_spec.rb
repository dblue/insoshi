require File.dirname(__FILE__) + '/../spec_helper'

describe PasswordRemindersController do
  integrate_views
  
  before(:each) do
    @emails = ActionMailer::Base.deliveries
    @emails.clear    
    @person = people(:quentin)
  end
  
  it "should render the new email reminder page" do
    get :new
    response.should be_success
    response.should render_template("new")
  end
  
  it "should deliver a reminder" do
    lambda do
      post :create, :person => { :email => @person.email }
      response.should be_redirect
    end.should change(@emails, :length).by(1)
  end
  
  it "should fail if it cannot find a valid person" do
    Person.stub!(:find_by_email).and_return(nil)
    post :create, :person => { :email => 'not_found' }
    response.should render_template(:new)
    flash.now[:error].should == "Invalid email address"
  end
  
  it "should redirect if email preferences have not been set" do
    @preference = preferences(:one)
    @preference.stub!(:can_send_email?).and_return(false)
    Preference.stub!(:find).and_return(@preference)
    get :new
    response.should redirect_to(home_url)
    flash[:error].should == "Invalid action"
  end
    
end
