require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  it "should be valid" do
    Forum.new.should be_valid
  end
  
  it "should have topics" do
    Factory(:forum).topics.should be_a_kind_of(Array)
  end
  
  it "should have posts" do
    Factory(:forum).posts.should be_a_kind_of(Array)
  end
end
