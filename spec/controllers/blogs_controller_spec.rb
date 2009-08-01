require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BlogsController do

  before(:each) do
    @person = login_as(:aaron)
  end
  
  def mock_blog(stubs={})
    stubs = {
      :save => true,
      :update_attributes => true,
      :destroy => true,
      :person => @person,
      :posts => []
    }.merge(stubs)
    @mock_blog ||= mock_model(Blog, stubs)
  end
  
  describe "GET 'show'" do
    it "should be successful" do
      Blog.stub!(:find).and_return(mock_blog)
      get :show, :id => "1"
      response.should be_success
    end
  end
end
