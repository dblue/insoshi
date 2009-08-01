require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do
  
  before(:each) do
    @filename = "rails.png"
    @person = people(:quentin)
    @gallery = galleries(:valid_gallery)
    @image = uploaded_file(@filename, "image/png")
  end
  
  it "should upload successfully" do
    new_photo.should be_valid
  end
  
  it "should be invalid without person_id" do
    @person = nil
    new_photo.should_not be_valid
  end
  
  it "should be invalid without gallery_id" do
    @gallery = nil
    new_photo.should_not be_valid
  end
  
  it "should only allow images to be uploaded" do
    image = uploaded_file(@filename, 'image/tiff')
    photo = new_photo(:uploaded_data => image)
    photo.should_not be_valid
    photo.errors.on(:base).should_not be_nil
  end

  it "should only allow images that are less than UPLOAD_LIMIT MB" do
    photo = new_photo()
    photo.stub!(:size).and_return(:size => Photo::UPLOAD_LIMIT + 1)
    photo.should_not be_valid
    photo.errors.on(:base).should_not be_nil
  end
  
  it "should have an associated person" do
    new_photo.person.should == @person
  end
  
  it "should not have default AttachmentFu errors for an empty image" do
    photo = new_photo(:uploaded_data => nil)
    photo.should_not be_valid
    photo.errors.on(:size).should be_nil
    photo.errors.on(:base).should_not be_nil
  end
  
  it "should have a label when the title is nil" do
    new_photo(:title => nil).label.should be_empty
  end
  
  it "should have a label when the title is present" do
    new_photo(:title => "a new photo").label.should == "a new photo"
  end
  
  it "should have a label from the filename" do
    new_photo.label_from_filename.should == "Rails"
  end
  private
  
    def new_photo(options = {})
      Photo.new({ :uploaded_data => @image,
                  :person        => @person,
                  :gallery       => @gallery }.merge(options))
    end
end