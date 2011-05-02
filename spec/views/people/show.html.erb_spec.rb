require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/show.html.erb" do
    
  before(:each) do
    @controller.params[:controller] = "people"
    @person = login_as(:person)
    @person.description = "Foo *bar*"
    @person.blog = Factory(:blog, :person => @person)
    @person.galleries = [Factory(:gallery, :person => @person)]
    assign(:person, @person)
    assign(:blog, @person.blog)
    assign(:posts, @person.blog.posts.paginate(:page => 1))
    assign(:galleries, @person.galleries.paginate(:page => 1))
    assign(:some_contacts, @person.some_contacts)
    assign(:common_contacts, [])
    render
  end

  it "should have the right title" do
    rendered.should contain(@person.name).within('h2')
  end
  
  it "should have a Markdown-ed description if BlueCloth is present" do
    begin
      BlueCloth.new("used to raise an exception")
      rendered.should contain('bar').within('em')
    rescue NameError
      nil
    end
  end 
end
