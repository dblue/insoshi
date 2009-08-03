require File.dirname(__FILE__) + '/../spec_helper'

describe SearchesHelper do
  
  include SearchesHelper
  
  describe "#search_model" do
    it "should support the home controller" do
      search_model_with(:controller => "home").should == "Person"
    end    
    it "should support the forums controller" do
      search_model_with(:controller => "forums").should == "ForumPost"
    end
    it "should support the Group controller" do
      search_model_with(:controller => "groups").should == "Group"
    end
    it "should support the Group action" do
      search_model_with(:action => "groups").should == "Group"
    end 
    it "should support other models when set explicitly" do
      search_model_with(:model => "Somemodel").should == "Somemodel"
    end
    it "should guess models from controllers" do
      search_model_with(:controller => "widgets").should == "Widget"
    end
  end

  describe "#search_type" do
    it "should recognize the forums controller" do
      search_type_with(:controller => "forums").should == "Forums"
    end
    it "should recognize the ForumPost model" do
      search_type_with(:model => "ForumPost").should == "Forums"
    end
    it "should recognize the messages controller" do
      search_type_with(:controller => "messages").should == "Messages"
    end
    it "should recognize the Messages model" do
      search_type_with(:model => "Message").should == "Messages"
    end
    it "should recognize the groups controller" do
      search_type_with(:controller => "groups").should == "Groups"
    end
    it "should recognize the Group model" do
      search_type_with(:model => "Group").should == "Groups"
    end
    it "should recognize the group action" do
      search_type_with(:action => "groups").should == "Groups"
    end
    it "should recognize the People search by default" do
      search_type_with.should == "People"
    end
  end

  describe "provide the partial (including path) for the given object" do
    describe "for non-admin searches" do
      before(:each) do
        helper.stub!(:admin_search?).and_return(false)
      end
      it "should handle the ForumPost object" do
        object = mock_model(ForumPost)
        helper.partial(object).should == "topics/search_result"
      end
      it "should handle the AllPerson object" do
        object = mock_model(AllPerson)
        helper.partial(object).should == "people/person"
      end
      it "should provide a default" do
        object = mock_model(Blog)
        helper.partial(object).should == "blogs/blog"
      end
    end
    describe "for admin searches" do
      before(:each) do
        helper.stub!(:admin_search?).and_return(true)
      end
      it "should handle the ForumPost object" do
        object = mock_model(ForumPost)
        helper.partial(object).should == "admin/topics/search_result"
      end
      it "should handle the AllPerson object" do
        object = mock_model(AllPerson)
        helper.partial(object).should == "admin/people/person"
      end
      it "should provide a default" do
        object = mock_model(Blog)
        helper.partial(object).should == "admin/blogs/blog"
      end
    end
  end
  
  private
  
  def search_model_with(options={})
    mock_params = {}.merge(options)
    helper.stub!(:params).and_return(mock_params)
    helper.search_model
  end  
  def search_type_with(options={})
    mock_params = 
      {:controller => "", :model => "", :action => ""}.merge(options)
    helper.stub!(:params).and_return(mock_params)
    helper.search_type
  end  
end
