require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  before(:each) do
    @person = Factory.create(:aaron)
    @commenter = Factory.create(:quentin)
  end

  it "should delete a post activity along with its parent item" do
    @post = Factory(:forum_post, :person => @person)
    destroy_should_remove_activity(@post)
  end
  
  it "should delete a comment activity along with its parent item" do
    @comment = Factory(:wall_comment, :person => @person,
                       :commenter => @commenter)
    destroy_should_remove_activity(@comment)
  end
  
  it "should delete topic & post activities along with the parent items" do
    @topic = Factory(:topic, :person => @person)
    post = Factory(:forum_post, :topic => @topic, :person => @person)
    @topic.posts.each do |post|
      destroy_should_remove_activity(post)
    end
    destroy_should_remove_activity(@topic)
  end
  
  it "should delete an associated connection" do
    @contact = Factory.create(:person)
    Connection.connect(@person, @contact)
    @connection = Connection.conn(@person, @contact)
    destroy_should_remove_activity(@connection, :breakup)
  end
    
  it "should have a nonempty global feed" do
    # create an activity
    @person.comments.unsafe_create(:body => "Hey there",
                                   :commenter => @commenter)
    Activity.global_feed.should_not be_empty
  end
  
  it "should not show activities for users who are inactive" do
    # create an activity
    @person.comments.unsafe_create(:body => "Hey there",
                                   :commenter => @commenter)
    @person.activities.collect(&:person).should include(@commenter)
    @commenter.toggle!(:deactivated)
    @commenter.should be_deactivated
    Activity.global_feed.should be_empty
    @person.reload
    @person.activities.collect(&:person).should_not include(@commenter)
  end
  
  it "should not show activities for users who are email unverified" do
    # create an activity
    @person.comments.unsafe_create(:body => "Hey there",
                                   :commenter => @commenter)
    @commenter.confirmed_at = nil; @commenter.save!
    Activity.global_feed.should be_empty
  end
  
  private
  
  # TODO: do this in a more RSpecky way.
  def destroy_should_remove_activity(obj, method = :destroy)
    Activity.find_by_item_id(obj).should_not be_nil
    obj.send(method)
    Activity.find_by_item_id(obj).should be_nil
  end
end
