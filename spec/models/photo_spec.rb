require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do
  
  before(:each) do
    @filename = "rails.png"
    @person = Factory(:person)
    @gallery = Factory(:gallery)
    @image = uploaded_file(@filename, "image/png")
  end
  
  it "should upload successfully" do
    Factory.build(:photo).should be_valid
  end
  
  it "should be invalid without person_id" do
    Factory.build(:photo, :person => nil).should_not be_valid
  end
  
  it "should be invalid without gallery_id" do
    Factory.build(:photo, :gallery => nil).should_not be_valid
  end
  
  
  it "should have an associated person" do
    Factory(:gallery, :person => @person).person.should == @person
  end
  
  it "should have errors for an empty image" do
    photo = Factory.build(:photo, :photo => nil)
    photo.should_not be_valid
    photo.errors[:size].should be_empty
    photo.errors[:base].should be_empty
    photo.errors[:photo].should_not be_empty
  end
end