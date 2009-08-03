require File.dirname(__FILE__) + '/../spec_helper'
include ActivitiesHelper
include SharedHelper
include PeopleHelper
describe ActivitiesHelper do

  before(:each) do
    @current_person = login_as(:aaron)
    # It sucks that RSpec makes me do this.
    self.stub!(:logged_in?).and_return(true)
    self.stub!(:current_person).and_return(people(:aaron))
  end

  describe "feedmessage" do

    it "should have the right message for a wall comment" do
      # Quentin comments an Aaron's wall
      person = @current_person
      commenter = people(:quentin)
      comment = person.comments.unsafe_create(:body => "The body",
                                              :commenter => commenter)
      activity = Activity.find_by_item_id(comment)
      # The message works even if logged in as Kelly.
      login_as(:kelly)
      feed_message(activity).should =~ /#{commenter.name}/
      feed_message(activity).should =~ /#{person.name}'s wall/
      feed_message(activity, true).should =~ /#{person.name}'s wall/

      # The message works even if logged in as the commenter
      login_as(commenter)
      feed_message(activity).should =~ /#{commenter.name}/
      feed_message(activity).should =~ /#{person.name}'s wall/
      feed_message(activity, true).should =~ /#{person.name}'s wall/
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
      feed_message(activity, true).should =~ /#{commenter.name}'s wall/
    end
  
    it "should have the right message for a blog comment" do
      post = posts(:blog_post)
      comment = post.comments.unsafe_create(:body => "The body", 
                                            :commenter => @current_person)
      activity = Activity.find_by_item_id(comment)
      feed_message(activity).should =~ /blog post/
      feed_message(activity, true).should =~ /blog post/
    end

    it "should have the right message for an event comment" do
      event = events(:public)
      comment = event.comments.unsafe_create(:body => "The body", 
                                            :commenter => @current_person)
      comment.save
      activity = Activity.find_by_item_id(comment)
      feed_message(activity).should =~ /event/
      feed_message(activity, true).should =~ /event/
    end
  
    it "should have the right message for a photo" do
      gallery = galleries(:aarons_gallery)
      @filename = "rails.png"
      @image = uploaded_file(@filename, "image/png")
      photo = Photo.new({:uploaded_data => @image, :person => @current_person, :gallery => gallery})
      photo.save
      activity = Activity.find_by_item_id(photo)
      feed_message(activity).should =~ /photo/
      feed_message(activity, true).should =~ /photo/
    end
  
    it "should have the right message for a blog post" do
      post = blogs(:one).posts.build(:title => "First post!",
                                     :body => "Hey there")
      post.save
      activity = Activity.find_by_item_id(post)
      feed_message(activity).should =~ /blogs/
      feed_message(activity, true).should =~ /blogs/
    end
  
    it "should have the right message for an event post" do
      event = Event.unsafe_build( :title => "value for title",
                                  :description => "value for description",
                                  :person => people(:aaron),
                                  :start_time => Time.now,
                                  :end_time => Time.now,
                                  :reminder => false,
                                  :privacy => 1 )
      event.save
      activity = Activity.find_by_item_id(event)
      feed_message(activity).should =~ /new event/
    end

    it "should have the right message for an event attendee" do
      event = events(:public)
      event_attendee = EventAttendee.new(:event => event,
                                         :person => current_person)
      event_attendee.save 
      activity = Activity.find_by_item_id(event_attendee)
      feed_message(activity).should =~ /is attending/
    end
  
    it "should have the right message for a new connection" do
      person = people(:quentin)
      contact = people(:aaron)
      admin = people(:admin)
    
      conn = establish_connection(person, contact)
      activity = Activity.find_by_item_id(conn)
      feed_message(activity).should =~ /have connected/
      feed_message(activity, true).should =~ /connected with/

      # TODO: Refactor and/or rethink this:
      # first_admin is prevented from getting connection activity.  
      Person.stub!(:find_first_admin).and_return(nil)    
      conn = establish_connection(person, admin)
      activity = Activity.find_by_item_id(conn)
      feed_message(activity).should =~ /has joined the system/
      feed_message(activity, true).should =~ /joined the system/
    end
  
    it "should have the right message for a forum post" do
      post = ForumPost.new(:body => "Hey there")
      post.topic  = topics(:one)
      post.person = people(:quentin)
      post.save
    
      activity = Activity.find_by_item_id(post)
      feed_message(activity).should =~ /made a post/
      feed_message(activity, true).should =~ /new post/
    end
  
    it "should have the right message for a new topic" do
      topic = forums(:one).topics.build(:name => "A topic")
      topic.person = people(:quentin)
      topic.save
    
      activity = Activity.find_by_item_id(topic)
      feed_message(activity).should =~ /new discussion topic/
      feed_message(activity, true).should =~ /new discussion topic/
    end
  
    it "should have the right message for change in a person's description" do
      person = @current_person
      person.description = "New description"
      person.save
    
      activity = Activity.find_by_person_id(person)
      feed_message(activity).should =~ /description changed/
      feed_message(activity, true).should =~ /description changed/
    end
  
    it "should have the right message for a new gallery" do
      gallery = Gallery.unsafe_create(:person => people(:kelly))
    
      activity = Activity.find_by_item_id(gallery)
      feed_message(activity).should =~ /added a new gallery/
      feed_message(activity, true).should =~ /new gallery/
    end

    it "should raise an error if the activity is unknown" do
      activity = mock_model(Activity, 
                            :person => @current_person,
                            :name => :unknown )
      self.stub!(:activity_type).and_return(:unknown)
      begin
        feed_message(activity).should raise_error(RuntimeError)
      rescue RuntimeError => e
        errmsg = e.message
      end
      errmsg.should =~ /Invalid activity type/
    end
  end

  # TODO: What is the difference between minifeed and feed?
  # Just the inclusion of recent on feed?
  describe "minifeed_message" do
    before(:each) do
      self.stub!(:feed_message).with(:any).and_raise
    end
    
    it "should have the right message for a blog post" do
      post = blogs(:one).posts.build(:title => "First post!",
                                     :body => "Hey there")
      post.save
      activity = Activity.find_by_item_id(post)
      minifeed_message(activity).should =~ /blogs/
    end
    
    it "should have the right message for a blog comment" do
      post = posts(:blog_post)
      comment = post.comments.unsafe_create(:body => "The body", 
      :commenter => @current_person)
      activity = Activity.find_by_item_id(comment)
      minifeed_message(activity).should =~ /blog post/
    end
    
    it "should have the right message for a wall comment" do
      # Quentin comments an Aaron's wall
      person = @current_person
      commenter = people(:quentin)
      comment = person.comments.unsafe_create(:body => "The body",
                                              :commenter => commenter)
      activity = Activity.find_by_item_id(comment)
      # The message works even if logged in as Kelly.
      login_as(:kelly)
      minifeed_message(activity).should =~ /#{commenter.name}/
    end
      
    it "should have the right message for an event comment" do
      event = events(:public)
      comment = event.comments.unsafe_create(:body => "The body", 
                                            :commenter => @current_person)
      activity = Activity.find_by_item_id(comment)
      minifeed_message(activity).should =~ /event/
    end
      
    it "should have the right message for a connection" do
      person = people(:quentin)
      contact = people(:aaron)
      admin = people(:admin)

      conn = establish_connection(person, contact)
      activity = Activity.find_by_item_id(conn)
      minifeed_message(activity).should =~ /have connected/

      # TODO: Refactor and/or rethink this:
      # first_admin is prevented from getting connection activity.  
      Person.stub!(:find_first_admin).and_return(nil)    
      conn = establish_connection(person, admin)
      activity = Activity.find_by_item_id(conn)
      minifeed_message(activity).should =~ /has joined the system/
    end
      
    it "should have the right message for a forum post" do
      post = ForumPost.new(:body => "Hey there")
      post.topic  = topics(:one)
      post.person = people(:quentin)
      post.save

      activity = Activity.find_by_item_id(post)
      minifeed_message(activity).should =~ /forum post/
    end
      
    it "should have the right message for a new topic" do
      topic = forums(:one).topics.build(:name => "A topic")
      topic.person = people(:quentin)
      topic.save
    
      activity = Activity.find_by_item_id(topic)
      minifeed_message(activity).should =~ /new discussion topic/
    end

    it "should have the right message for a change in a person's description" do
      person = @current_person
      person.description = "New description"
      person.save

      activity = Activity.find_by_person_id(person)
      minifeed_message(activity).should =~ /description has changed/
    end

    it "should have the right message for a new gallery" do
      gallery = Gallery.unsafe_create(:person => people(:kelly))

      activity = Activity.find_by_item_id(gallery)
      minifeed_message(activity).should =~ /added a new gallery/
    end
      
    it "should have the right message for a new photo" do
      gallery = galleries(:aarons_gallery)
      @filename = "rails.png"
      @image = uploaded_file(@filename, "image/png")
      photo = Photo.new({:uploaded_data => @image, :person => @current_person, :gallery => gallery})
      photo.save
      activity = Activity.find_by_item_id(photo)
      minifeed_message(activity).should =~ /photo/
    end
    
    it "should have the right message for a new event" do
      event = Event.unsafe_build( :title => "value for title",
                                  :description => "value for description",
                                  :person => people(:aaron),
                                  :start_time => Time.now,
                                  :end_time => Time.now,
                                  :reminder => false,
                                  :privacy => 1 )
      event.save
      activity = Activity.find_by_item_id(event)
      minifeed_message(activity).should =~ /event/
    end
    
    it "should have the right message for an event attendee" do
      event = events(:public)
      event_attendee = EventAttendee.new(:event => event,
                                         :person => current_person)
      event_attendee.save 
      activity = Activity.find_by_item_id(event_attendee)
      minifeed_message(activity).should =~ /is attending/
    end
      
    it "should raise an error if the activity is unknown" do
      activity = mock_model(Activity, 
                            :person => @current_person,
                            :name => :unknown )
      self.stub!(:activity_type).and_return(:unknown)
      begin
        minifeed_message(activity).should raise_error(RuntimeError)
      rescue RuntimeError => e
        errmsg = e.message
      end
      errmsg.should =~ /Invalid activity type/
    end    
  end
  
  describe "feed_icon" do
    it "should handle the basic feed icons" do
      # handle the easy ones
      [ [BlogPost, nil, "page_white.png"],
        [Comment, BlogPost, "comment.png"],
        [Comment, Event, "comment.png"],
        [Comment, Person, "sound.png"],
        [ForumPost, nil, "asterisk_yellow.png"],
        [Topic, nil, "note.png"],
        [Person, nil, "user_edit.png"],
        [Gallery, nil, "photos.png"],
        [Photo, nil, "photo.png"],
        [Event, nil, "time.gif"],
        [EventAttendee, nil, "check.gif"]
      ].each do |activity_type, sub_type, icon|
        test_feed_icon(activity_type, sub_type, icon)
      end
    end
    
    it "should handle the complex feed icons" do
      item = mock_model(Connection,
                        :contact => people(:admin))
      activity = mock_model(Activity,
                            :item => item)
      feed_icon(activity).should =~ /vcard.png/
      
      item = mock_model(Connection,
                        :contact => people(:quentin))
      activity = mock_model(Activity,
                            :item => item)  
      feed_icon(activity).should =~ /connect.png/
    end
    
    it "should handle the exceptions" do
      activity = mock_model(Activity,
                            :item => :unknown)
      begin
        feed_icon(activity).should raise_error(RuntimeError)
      rescue RuntimeError => e
        errmsg = e.message
      end
      errmsg.should =~ /Invalid activity type/
    end
  end

  it "should generate gallery links" do
    to_gallery_link().should == ''
    gallery = galleries(:valid_gallery)
    to_gallery_link(gallery.title, gallery).should =~ /Title/
  end
  
  it "should show member photos for certain types of activities" do
    item = mock_model(Photo)
    activity = mock_model(Activity,
                          :item => item,
                          :person => people(:quentin))
    posterPhoto(activity).should =~ /img/

    item = mock_model(Connection)
    activity = mock_model(Activity,
                          :item => item,
                          :person => people(:quentin))
    posterPhoto(activity).should =~ /img/

    item = mock_model(Event)
    activity = mock_model(Activity,
                          :item => item,
                          :person => people(:quentin))
    posterPhoto(activity).should be_nil
  end
  
  private 
  
  def establish_connection(person, contact)
    Connection.request(person, contact)
    Connection.accept(person, contact)
    return Connection.conn(person, contact)
  end

  #TODO: create a generator for these activity/item combos
  def activity_with_item()
  end
  
  def test_feed_icon(activity_item, sub_type, icon)
    
    commentable = sub_type ? mock_model(sub_type) : nil
    item = mock_model(activity_item,
                      :commentable => commentable)
    activity = mock_model(Activity,
                          :item => item)
    feed_icon(activity).should =~ /#{icon}/
  end

end
