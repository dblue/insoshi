require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Event do
  it "should create a new instance given valid attributes" do
    Factory(:event).should be_valid
  end

  describe "privacy settings" do
    before(:each) do
      @person = Factory.create(:aaron)
      @contact = Factory.create(:quentin)
      Connection.connect(@person, @contact)
      @event = Factory.create(:event, :person => @person)
      @private = Factory.create(:event, :person => @contact, :privacy => 2)
    end
    
    it "should find all public events" do
      Event.person_events(@person).should include(@event)
    end

    it "should find contact's events" do
      # @person.stub!(:contact_ids).and_return([@contact.id])
      Event.person_events(@person).should include(@private)
    end

    it "should find own events" do
      Event.person_events(@contact).should include(@private)
    end                   
    
    it 'should not find other private events who are not my friends' do
      @not_a_friend = Factory(:person)
      Event.person_events(@not_a_friend).should_not include(@private)
    end
                                       
  end

  describe "attendees association" do
    before(:each) do
      @event = Factory(:event)
      @person = Factory(:person)
    end
    
    it "should allow people to attend" do
      @event.attend(@person)                                   
      @event.attendees.should include(@person)
      @event.reload
      @event.event_attendees_count.should be(1)
    end

    it 'should not allow people to attend twice' do
      @event.attend(@person).should_not be_nil
      @event.attend(@person).should be_nil
    end
                                        
  end

  describe "comments association" do
    before(:each) do
      @event = Factory(:event)
    end

    it "should have many comments" do
      @event.comments.create Factory.attributes_for(:event_comment)
      @event.comments.should be_a_kind_of(Array)
      @event.comments.should_not be_empty
    end
  end

  describe 'event activity association' do
    before(:each) do
      @event = Factory(:event)
      @activity = Activity.find_by_item_id(@event)
    end
    
    it "should have an activity" do
      @activity.should_not be_nil
    end
    
    it "should add an activity to the creator" do
      @event.person.recent_activity.should contain(@activity)
    end
  end

end
