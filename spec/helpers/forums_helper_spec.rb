require File.dirname(__FILE__) + '/../spec_helper'

describe ForumsHelper do
  
  include ForumsHelper
  
  it "should set the forum name when a name is provided" do
    forum = stub(:name => "test forum")
    forum_name(forum).should == "test forum"
  end
  
  it "should assign a generic name when no name is provided" do
    [nil, ""].each do |name|
      forum = stub(:name => name, :id => 23)
      forum_name(forum).should == "Forum #23"
    end
  end
  
end
