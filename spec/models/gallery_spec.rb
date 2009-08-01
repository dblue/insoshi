require File.dirname(__FILE__) + '/../spec_helper'

describe Gallery do
  before(:each) do
    @gallery = galleries(:valid_gallery)
  end

  it "should be valid" do
    @gallery.should be_valid
  end
  
  it "should require person_id" do
    @gallery = galleries(:invalid_gallery)
    @gallery.should_not be_valid
    @gallery.errors.on(:person_id).should_not be_empty
  end
    
  it "should have a max title length" do
    @gallery.should have_maximum(:title, 255)
  end
  
  it "should have a max description length" do
    @gallery.should have_maximum(:description, 1000)
  end
  
  it "should have many photos" do
    @gallery.photos.should be_kind_of(Array)
  end
  
  it "should have an activity" do
    @gallery = Gallery.unsafe_create(:person => people(:kelly))
    Activity.find_by_item_id(@gallery).should_not be_nil
  end

  describe "primary photo" do
    it "should set its primary photo" do
      photo = mock_model(Photo, :nil? => false)
      @gallery.primary_photo = photo
      @gallery.primary_photo_id.should == photo.id
    end

    describe "when set" do
      before(:each) do
        photo = mock_model(Photo, :nil? => false, :public_filename => "test.png")
        @gallery.stub!(:primary_photo).and_return(photo)
      end
      it "should return its primary photo URL" do
        @gallery.primary_photo_url.should == 'test.png'
      end
      it "should return its thumbnail URL" do
        @gallery.thumbnail_url.should == 'test.png'
      end
      it "should return its icon URL" do
        @gallery.icon_url.should == 'test.png'
      end
      it "should return its bounded icon URL" do
        @gallery.bounded_icon_url.should == 'test.png'
      end
    end
    
    describe "when not set" do
      before(:each) do
        photo = mock_model(Photo, :nil? => true)
        @gallery.primary_photo = photo
      end  
      it "should set its primary photo to nil when there is no photo" do
        @gallery.primary_photo_id.should be_nil
      end  
      it "should return a default photo URL" do
        @gallery.primary_photo_url.should == 'default.png'
      end
      it "should return a default thumbnail URL" do
        @gallery.thumbnail_url.should == 'default_thumbnail.png'
      end  
      it "should return a default icon URL" do
        @gallery.icon_url.should == 'default_icon.png'
      end
      it "should return a default thumbnail URL" do
        @gallery.bounded_icon_url.should == 'default_icon.png'
      end
    end
  end
end
