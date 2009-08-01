require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PeopleHelper do
  include PeopleHelper
  
  # describe "#message_links(people)" do
  #   it "should provide a list of email links" do
  #   end
  # end

  describe "image_link" do
    before(:each) do
      @person = people(:quentin)
    end
    it "should return a person's image link" do
      helper.image_link(@person).should =~ /Quentin/
    end
    it "should include image options" do
      helper.image_link(@person, {:image_options => {:class => "thumbnail"}}).should =~ /thumbnail/
    end
    it "should include link options" do
      helper.image_link(@person, {:link_options => {:title => "My Title"}}).should =~ /My Title/
    end
    it "should include vcard if required" do
      helper.image_link(@person, {:vcard => true}).should =~ /fn/
    end
  end

  describe "person_link" do
    before(:each) do
      @person = people(:quentin)
    end    
    it "should provide a link when the person is nil" do
      helper.person_link(@person).should have_tag("a[href]")
    end
    it "should provide a link when a person is included" do
      link = person_link("Better Description", @person)
      link.should have_tag("a[href]")
      link.should =~ /Better Description/
    end
  end

  describe "person_link_with_image" do
    before(:each) do
      @person = people(:quentin)
    end    
    it "should provide a link when the person is nil" do
      helper.person_link_with_image(@person).should have_tag("a[href]")
    end
    it "should provide a link when a person is included" do
      link = helper.person_link_with_image("Better Description", @person)
      link.should have_tag("a[href]")
      link.should =~ /Better Description/
    end    
  end

  describe "#person_image_hover_text(text, person, html_options = nil)" do
  end

  describe "#activated_status(person)" do
  end

  describe "#captioned(images, captions)" do
  end
end