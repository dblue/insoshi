require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/blogs/show" do
  before(:each) do
    @person = login_as(:aaron)
    Blog.stub!(:find).and_return(mock_blog)
    render 'blogs/show'
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
end
