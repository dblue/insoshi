require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessagesHelper do
  include MessagesHelper
  
  describe "#list_link_with_active" do
    it "should generate a content tag" do
      helper.stub!(:current_page?).and_return(false)      
      helper.list_link_with_active("Inbox", messages_path).should == '<li><a href="/messages">Inbox</a></li>'
    end
    it "should generate a content tag with active set" do
      helper.stub!(:current_page?).and_return(true)
      helper.list_link_with_active("Inbox", messages_path).should == '<li class="active"><a href="/messages">Inbox</a></li>'
    end
  end
  
  describe "#message_icon" do
    it "should provide the correct icon for a new message" do
      message = mock_model(Message, :new? => true)
      helper.stub!(:current_person)
      helper.message_icon(message).should =~ /email_add\.png/
    end
    it "should provide the correct icon for a reply message" do
      message = mock_model(Message, :new? => false, :replied_to? => true)
      helper.stub!(:current_person)
      helper.message_icon(message).should =~ /email_go\.png/
    end
  end
end
