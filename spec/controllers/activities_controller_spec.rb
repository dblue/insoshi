require File.dirname(__FILE__) + '/../spec_helper'

describe ActivitiesController do
  
  before(:each) do
    @person  = login_as(:quentin)
    @commenter = login_as(:aaron)
    @person.comments.unsafe_create(:body => "Hey there",
                                   :commenter => @commenter)
    @activity = @commenter.recent_activity.first
  end
  
  it "should allow destroy" do
    login_as @commenter
    delete :destroy, :id => @activity
    @activity.should_not exist_in_database
  end
  
  it "should require the correct user to destroy an activity" do
    login_as @person
    delete :destroy, :id => @activity
    response.should redirect_to(home_url)
  end
  
  it "should allow show for an activity" do
    get :show, :id => @activity
    response.body.should == ''
  end
  
end