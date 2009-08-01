require File.dirname(__FILE__) + '/../spec_helper'

describe CommunicationsHelper do
  
  include CommunicationsHelper
  
  it "should provide contact links for requested contacts" do
    @current_person = login_as(:admin)
    stub!(:current_person).and_return(@current_person)
    @contacts = [people(:aaron), people(:quentin), people(:kelly)]
    @contacts.each do |contact|
      Connection.connect(@current_person, contact)
    end
    contact_links(@contacts).each do |link|
      link.should =~ /connections\/\d+\/edit/
    end
  end
  
  it "should respond to message_anchor" do
    @message = mock_model(Message, :id => "12")
    message_anchor(@message).should == "message_12"
  end
end
