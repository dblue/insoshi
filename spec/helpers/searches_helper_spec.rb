require File.dirname(__FILE__) + '/../spec_helper'

describe SearchesHelper do
  
  include SearchesHelper
  
  describe "determine the model to be searched based on parameters" do
    it "should support the home controller" do
      mock_params = { :controller => "home"}
      helper.stub!(:params).and_return(mock_params)
      helper.search_model.should == "Person"
    end
    
    it "should support the forums controller" do
      mock_params = { :controller => "forums"}
      helper.stub!(:params).and_return(mock_params)
      helper.search_model.should == "ForumPost"
    end
    
    it "should support other models when set explicitly" do
      mock_params = { :model => "somemodel"}
      helper.stub!(:params).and_return(mock_params)
      helper.search_model.should == "somemodel"
    end
    
    it "should guess models from controllers" do
      mock_params = { :controller => "widgets"}
      helper.stub!(:params).and_return(mock_params)
      helper.search_model.should == "Widget"
    end
  end

  describe "provide the search type in English based on the controller" do
    it "should recognize the forums controller" do
      mock_params = { :controller => "forums"}
      helper.stub!(:params).and_return(mock_params)
      helper.search_type.should == "Forums"
    end
    it "should recognize the ForumPost model" do
      mock_params = { :model => "ForumPost"}
      helper.stub!(:params).and_return(mock_params)
      helper.search_type.should == "Forums"
    end
    it "should recognize the messages controller" do
      mock_params = { :controller => "messages"}
      helper.stub!(:params).and_return(mock_params)
      helper.search_type.should == "Messages"
    end
    it "should recognize the Messages model" do
      mock_params = { :model => "Message"}
      helper.stub!(:params).and_return(mock_params)
      helper.search_type.should == "Messages"
    end
    it "should recognize the People search by default" do
      mock_params = {}
      helper.stub!(:params).and_return(mock_params)
      helper.search_type.should == "People"
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
end
