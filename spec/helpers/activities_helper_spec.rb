require File.dirname(__FILE__) + '/../spec_helper'
include ActivitiesHelper
include SharedHelper
include PeopleHelper


describe ActivitiesHelper do

  before(:each) do
    @current_person = login_as(:aaron)
    @gallery = Factory(:gallery, :person => @current_person)
  end
  
  it "should have the right message for a wall comment" do
    # Quentin comments an Aaron's wall
    person = @current_person
    commenter = Factory.create(:quentin)
    comment = Factory(:wall_comment, :commenter => commenter, :commentable => person)
    activity = Activity.find_by_item_id(comment)

    # The message works even if logged in as Kelly.
    login_as(:kelly)
    feed_message(activity).should =~ /#{commenter.name}/
    feed_message(activity).should =~ /#{person.name}'s wall/

    # The message works even if logged in as the commenter
    login_as(commenter)
    feed_message(activity).should =~ /#{commenter.name}/
    feed_message(activity).should =~ /#{person.name}'s wall/
  end

  it "should have the right message for an own-comment" do
    person = @current_person
    commenter = @current_person
    comment = person.comments.unsafe_create(:body => "The body", 
                                            :commenter => commenter)
    activity = Activity.find_by_item_id(comment)
    login_as(:kelly)
    feed_message(activity).should =~ /#{commenter.name}/
    feed_message(activity).should =~ /#{commenter.name}'s wall/
  end
  
  
  it "should have the right message for a blog comment" do
    post = Factory(:blog_post)
    comment = Factory(:blog_comment, :commenter => @current_person, :commentable => post)
    activity = Activity.find_by_item_id(comment)
    feed_message(activity).should =~ /blog post/
  end
  
  it "should have the right message for a photo" do
    @filename = "rails.png"
    @image = uploaded_file(@filename, "image/png")
    photo = Factory(:photo, :person => @current_person, :gallery => @gallery)
    photo.save
    activity = Activity.find_by_item_id(photo)
    feed_message(activity).should =~ /photo/
  end
end
