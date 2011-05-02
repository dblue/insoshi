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
      rendered.should contain(new_person_session_path).within('a')
    end
  
    it "should have a signup link" do
      rendered.should contain(new_person_registration_path).within('a')
    end
  
    it "should not have a sign out link" do
      rendered.should_not contain(destroy_person_session_path).within('a')
    end
  
    it "should have the right analytics" do
      Preference.current.update_attributes!(:analytics => "Google analytics")
      render
      rendered.should contain("Google analytics") #.within('script')
    end
  end

  describe "layout when logged in" do
  
    before(:each) do
      @person = login_as :quentin
      render
    end
  
    it "should not have a login link" do
      rendered.should_not contain(new_person_session_path).within('a')
    end
  
    it "should not have a signup link" do
      rendered.should_not contain(new_person_registration_path).within('a')
    end
  
    it "should have a sign out link" do
      rendered.should contain(destroy_person_session_path).within('a')
    end
  
    it "should have a profile link" do
      rendered.should match( person_path(@person))
    end
  end
end