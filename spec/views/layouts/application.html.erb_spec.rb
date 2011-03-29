require File.dirname(__FILE__) + '/../../spec_helper'

describe "/layouts/application.html.erb" do
  describe "layout when not logged in" do
    before(:each) do
      render
    end
  
    it "should have the right DOCTYPE declaration" do
      rendered.should match(/XHTML 1.0 Strict/)
    end
  
    it "should have a login link" do
      rendered.should have_selector('a', :href => new_person_session_path)
    end
  
    it "should have a signup link" do
      rendered.should have_selector('a', :href => new_person_registration_path)
    end
  
    it "should not have a sign out link" do
      rendered.should_not have_selector('a', :href => destroy_person_session_path)
    end
  
    it "should have the right analytics" do
      rendered.should have_selector("script", :content => "Google analytics")
    end
  end

  describe "layout when logged in" do
  
    before(:each) do
      @person = login_as :quentin
      render
    end
  
    it "should not have a login link" do
      rendered.should_not have_selector('a', :href => new_person_session_path)
    end
  
    it "should not have a signup link" do
      rendered.should_not have_selector('a', :href => new_person_registration_path)
    end
  
    it "should have a sign out link" do
      rendered.should have_selector('a', :href => destroy_person_session_path)
    end
  
    it "should have a profile link" do
      rendered.should match( person_path(@person))
    end
  end
end