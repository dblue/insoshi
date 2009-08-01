require File.dirname(__FILE__) + '/../spec_helper'

describe HomeController do
  describe "when logged in" do
    it "should respond to index" do
      login_as(:quentin)
      get :index
      response.should be_success
    end
  end
  
  describe "when not logged in" do
    it "should respond to index" do
      logout
      get :index
      response.should be_success 
    end
  end
end