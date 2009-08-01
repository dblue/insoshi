require File.dirname(__FILE__) + '/../spec_helper'

describe GalleriesController do
  describe "when not logged in" do
      
    it "should protect the index page" do
      get :index
      response.should redirect_to(login_url)
    end
  end
  
  describe "when logged in" do
    integrate_views
  
    before(:each) do
      @gallery = galleries(:valid_gallery)
      @person  = people(:quentin)
      @person.galleries.create(:title => "the title")
      login_as(:quentin)
    end
    
    it "should have working pages" do |page|
      page.get    :index,   :person_id => @person   
      response.should be_success
      
      page.get    :show,    :id => @gallery        
      response.should be_success
      
      page.get    :new                              
      response.should be_success
      
      page.get    :edit,    :id => @gallery
      response.should be_success
      
      page.post   :create, :gallery => { :title       => "foo",
                                         :description => "bar" }
      gallery = assigns(:gallery)
      gallery.title.should == "foo"
      gallery.description.should == "bar"
      gallery.person.should == @person
      
      page.delete :destroy, :id => @gallery
      @gallery.should_not exist_in_database
    end
    
    describe "with an unsuccessful create" do
      before :each do
        Gallery.stub!(:new).and_return(@gallery)
        @gallery.stub!(:save).and_return(false)
      end
      
      it "should assign @gallery" do
        post :create, :gallery => {}
        gallery = assigns(:gallery)
        gallery.title.should == "Title"
        gallery.description.should == "Some description"
      end
      
      it "should put a message in flash[:error]" do
        post :create, :gallery => {}
        flash[:error].should == nil
      end
      
      it "should render the new template" do
        post :create, :gallery => {}
        response.should render_template(:new)
      end  
    end
    
    describe "with a successful update" do
      # before :each do
      #   Gallery.stub!(:new).and_return(@gallery)
      #   @gallery.stub!(:save).and_return(true)
      # end

      it "should assign @gallery" do
        post :update, :id => @gallery
        gallery = assigns(:gallery)
        gallery.title.should == "Title"
        gallery.description.should == "Some description"
      end
      
      it "should put a message in flash[:success]" do
        post :update, :id => @gallery
        flash[:success].should == "Gallery successfully updated"
      end
      
      it "should redirect" do
        post :update, :id => @gallery
        response.should redirect_to( gallery_path(@gallery))
      end
    end
    
    describe "with an unsuccessful update" do
      before :each do
        Gallery.stub!(:find).and_return(@gallery)
        @gallery.stub!(:update_attributes).and_return(false)
      end
      
      it "should assign @gallery" do
        post :update, :id => @gallery
        gallery = assigns(:gallery)
        gallery.title.should == "Title"
        gallery.description.should == "Some description"
      end
      
      it "should render new" do
        post :update, :id => @gallery
        response.should render_template(:new)
      end
    end

    it "should associate person to the gallery" do
      post :create, :gallery => {:title=>"Title"}
      assigns(:gallery).person.should == @person
    end
    
    it "should require the correct user to edit" do
      login_as(:kelly)
      post :edit, :id => @gallery
      response.should redirect_to(person_galleries_url(@person))
    end
    
    it "should require the correct user to delete" do
      login_as(:kelly)
      delete :destroy, :id => @gallery
      response.should redirect_to(person_galleries_url(@person))
    end
    
    it "should not destroy the final gallery" do
      delete :destroy, :id => @person.galleries.first
      flash[:success].should =~ /successfully deleted/
      delete :destroy, :id => @person.reload.galleries.first
      flash[:error].should =~ /can't delete the final gallery/
    end
    
    it "should set a flash error if the gallery could not be deleted" do
      Gallery.stub!(:find).and_return(@gallery)
      @gallery.stub!(:destroy).and_return(false)
      delete :destroy, :id => @gallery
      flash[:error].should == "Gallery could not be deleted"
    end
    
    it "should set a flash error if a gallery cannot be found" do
      Gallery.stub!(:find).and_return(nil)
      delete :destroy, :id => @gallery
      flash[:error].should == "No gallery found"
    end

    it "should redirect if a gallery cannot be found" do
      Gallery.stub!(:find).and_return(nil)
      delete :destroy, :id => @gallery
      response.should redirect_to(person_galleries_path(@person))
    end
  end
end
