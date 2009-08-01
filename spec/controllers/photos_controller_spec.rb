require File.dirname(__FILE__) + '/../spec_helper'
require "thumbnail"

class Thumbnail

  # Override full_filename to avoid writing files to the public image directory.
  # They go instead to Dir::tmpdir, which on *nix systems is usually /tmp.
  # See http://www.fngtps.com/2007/04/testing-with-attachment_fu for more info.  
  def full_filename(thumbnail = nil)
    klass = thumbnail.nil? ? self : thumbnail_class
    file_system_path = klass.attachment_options[:path_prefix].to_s
    File.join(Dir::tmpdir, file_system_path,
              *partitioned_path(thumbnail_name_for(thumbnail)))
  end
end

describe PhotosController do

  describe "when not logged in" do
      
    it "should protect the index page" do
      get :index
      response.should redirect_to(login_url)
    end
  end

  describe "when logged in" do
    integrate_views
    
    before(:each) do

      @person = login_as(:quentin)
      @gallery = galleries(:valid_gallery)
      
      @filename = "rails.png"
      @image = uploaded_file(@filename, "image/png")
      @primary = Photo.create(:uploaded_data => @image,
                              :person => people(:quentin),
                              :gallery => @gallery,
                              :avatar => true, 
                              :primary => true,
                              :title => "primary")
      @secondary = Photo.create(:uploaded_data => @image,
                                :person => people(:quentin),
                                :gallery => @gallery,
                                :avatar => false,
                                :primary => false,
                                :title => "secondary")
      @photo = @primary
    end
  
    it "should redirect from the index page" do
      get :index
      response.should redirect_to(person_galleries_path(@person))
    end
    
    it "should respond to show" do
      get :show, :id => @photo
      response.should be_success
    end
    
    it "should have a new photo page" do
      get :new, :gallery_id => @gallery
      response.should be_success
      response.should render_template("new")
    end
    
    it "should not have a new photo page without given gallery id" do
      get :new
      response.should_not be_success
    end

    it "should have an edit photo page" do
      Photo.should_receive(:find).and_return(@photo)
      get :edit, :id => @photo
      response.should be_success
      response.should render_template("edit")
    end
    
    it "should respond to a successful update" do
      Photo.stub!(:find).and_return(@photo)
      @photo.should_receive(:update_attributes).and_return(true)
      post :update, :id => @photo
      response.should redirect_to(gallery_path(@photo.gallery))
      flash[:success].should == "Photo successfully updated"
    end
    
    it "should respond to an unsuccessful update" do
      Photo.stub!(:find).and_return(@photo)
      @photo.should_receive(:update_attributes).and_return(false)
      post :update, :id => @photo
      response.should render_template(:edit)
    end
    
    it "should create photo" do
      image = uploaded_file("rails.png")
      lambda do
        post :create, :photo => { :uploaded_data => image},
                      :gallery_id => @gallery
      end.should change(Photo, :count).by(1)
    end
    
    it "should handle empty photo upload" do
      lambda do
        post :create, :photo => { :uploaded_data => nil },
                      :gallery_id => @gallery
        response.should render_template("new")
      end.should_not change(Photo, :count)
    end
        
    it "should handle nil photo parameter" do
      post :create, :photo => nil, :gallery_id => @gallery
      response.should redirect_to(gallery_url(@gallery))
      flash[:error].should_not be_nil
    end
    
    it "should destroy a photo" do
      Photo.should_receive(:find).and_return(@secondary)
      @secondary.should_receive(:destroy).and_return(true)
      delete :destroy, :id => @secondary
    end
    
    it "should require the correct user to edit" do
      login_as :aaron
      Photo.should_receive(:find).and_return(@photo)
      get :edit, :id => @photo
      response.should redirect_to(home_url)
    end
    
    it "should be able to set the photo as avatar" do
      put :set_avatar, :id => @secondary.id
      response.should redirect_to(person_path(@person))
      @secondary = Photo.find(@secondary.id)
      @secondary.avatar.should be_true
      @primary = Photo.find(@primary.id)
      @primary.avatar.should_not be_true
    end
    
    it "should not set the photo as avatar if it is already the avatar" do
      put :set_avatar, :id => @primary
      response.should redirect_to(person_path(@person))
    end

    it "should not set the photo as avatar if it is nil" do
      @primary.stub!(:nil?).and_return(true)
      put :set_avatar, :id => @primary      
      response.should redirect_to(person_path(@person))
    end
    
    it "should fail gracefully if it could not save the photo as an avatar" do
      @failed = mock_model( Photo,
                            :uploaded_data => @image,
                            :person => people(:quentin),
                            :gallery => @gallery,
                            :avatar => false,
                            :avatar? => false,
                            :primary => false,
                            :primary? => false,
                            :title => "failed",
                            :update_attributes! => false)
      Photo.stub!(:find).with(:failed).and_return(@failed)
      
      # This stub handles the call for @old_primary
      Photo.should_receive(:find).with(:all, anything()).and_return([])
      put :set_avatar, :id => :failed
      response.should redirect_to(home_url)
      flash[:error].should == "Invalid image!"
    end
    
    it "should be able to set the photo as primary for the gallery" do
      put :set_primary, :id => @secondary
      response.should redirect_to(person_galleries_url(@person))
      
      @secondary = Photo.find(@secondary.id)
      @secondary.primary.should be_true
      @primary = Photo.find(@primary.id)
      @primary.primary.should_not be_true
    
    end
    
    it "should not set the photo as primary for the gallery if it is already primary" do
      put :set_primary, :id => @primary
      response.should redirect_to(person_galleries_url(@person))
    end
    
    it "should not set the photo as primary for the gallery if it is nil" do
      @primary.stub!(:find).and_return(nil)
      put :set_primary, :id => @primary
      response.should redirect_to(person_galleries_url(@person))
    end
    
    it "should fail gracefully if it could not set the photo as primary" do
      @failed = mock_model( Photo,
                            :uploaded_data => @image,
                            :person => people(:quentin),
                            :gallery => @gallery,
                            :avatar => false,
                            :primary => false,
                            :primary? => false,
                            :title => "failed",
                            :update_attributes => false)
      Photo.stub!(:find).with(:failed).and_return(@failed)
      
      # This stub handles the call for @old_primary
      Photo.should_receive(:find).with(:all, anything()).and_return([])
      put :set_primary, :id => :failed
      response.should redirect_to(home_url)
      flash[:error].should == "Invalid image!"
    end
    
    it "should redirect when the photo is nil and correct user is required" do
      Photo.should_receive(:find).and_return(nil)
      get :edit, :id => @photo
      flash[:error].should == "Photo could not be loaded!"
      response.should redirect_to(home_url)
    end
    
    it "should redirect when the gallery is not owned by the current user" do
      @person = login_as(:aaron)
      get :new, :gallery_id => @gallery
      flash[:error].should == "You cannot add photos to this gallery"
      response.should redirect_to(gallery_path(@gallery))
    end
  end
end
