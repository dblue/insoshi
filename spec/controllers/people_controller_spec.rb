require File.dirname(__FILE__) + '/../spec_helper'

describe PeopleController do

  before(:each) do
    @person = login_as(:aaron)
    photos = [Factory(:photo, :primary => true), Factory(:photo)]
    photos.stub!(:find_all_by_primary).and_return(photos.select(&:primary?))
    @person.stub!(:photos).and_return(photos)
  end
  
  describe "people pages" do
    render_views
        
    it "should have a working index" do
      get :index
      response.should be_success
      response.should render_template("index")
    end

    it "should have a working new page" do
      get :new
      response.should be_success
      response.should render_template("new")
    end
    
    it "should allow non-logged-in users to view new page" do
      sign_out :person
      get :new
      response.should be_success
    end
    
    it "should have a working show page" do
      get :show, :id => @person
      response.should be_success
      response.should render_template("show")
    end
    
    it "should have a working edit page" do
      login_as @person
      get :edit, :id => @person
      response.should be_success
      response.should render_template("edit")
    end
    
    it "should redirect to home for deactivated users" do
      @person.toggle!(:deactivated)
      get :show, :id => @person
      response.should redirect_to(home_url)
      flash[:error].should =~ /not active/
    end
    
    it "should redirect to sign-in for email unverified users" do
      enable_email_notifications
      @person.confirmed_at = nil; @person.save!
      @person.should_not be_active
      get :show, :id => @person
      response.should redirect_to(new_person_session_path)
      flash[:alert].should =~ /confirm your account/
    end
  end

  ## DEVISE now handles this.
  
  # describe "create" do
  #   render_views
  #   
  #   before(:each) do
  #     sign_out :person
  #   end
  # 
  #   it 'allows signup' do
  #     lambda do
  #       create_person
  #       response.should be_redirect      
  #     end.should change(Person, :count).by(1)
  #   end
  # 
  #   it 'requires password on signup' do
  #     lambda do
  #       create_person(:password => nil)
  #       assigns[:person].errors[:password].should_not be_nil
  #       response.should be_success
  #     end.should_not change(Person, :count)
  #   end
  # 
  #   it 'requires password confirmation on signup' do
  #     lambda do
  #       create_person(:password_confirmation => nil)
  #       assigns[:person].errors[:password_confirmation].should_not be_nil
  #       response.should be_success
  #     end.should_not change(Person, :count)
  #   end
  # 
  #   it 'requires email on signup' do
  #     lambda do
  #       create_person(:email => nil)
  #       assigns[:person].errors[:email].should_not be_nil
  #       response.should be_success
  #     end.should_not change(Person, :count)
  #   end
  #   
  #   describe "email verifications" do
  #     
  #     before(:each) do
  #       sign_out :person
  #       @preferences = preferences(:one)
  #     end
  #     
  #     describe "when not verifying email" do
  #       it "should create an active user" do
  #         create_person
  #         assigns(:person).should_not be_deactivated
  #       end
  #     end
  #     
  #   end
  # end
  
  describe "edit" do
    render_views
    
    before(:each) do
      @person = login_as(:quentin)
    end
    
    it "should render the edit page when photos are present" do
      get :edit, :id => @person
      response.should be_success
      response.should render_template("edit")
    end
    
    it "should allow mass assignment to name" do
      put :update, :id => @person, :person => { :name => "Foo Bar" },
                   :type => "info_edit"
      assigns(:person).name.should == "Foo Bar"
      response.should redirect_to(person_url(assigns(:person)))
    end
      
    it "should allow mass assignment to description" do
      put :update, :id => @person, :person => { :description => "Me!" },
                   :type => "info_edit"
      assigns(:person).description.should == "Me!"
      response.should redirect_to(person_url(assigns(:person)))
    end
    
    it "should render edit page on invalid update" do
      put :update, :id => @person, :person => { :email => "foo" },
                   :type => "info_edit"
      response.should be_success
      response.should render_template("edit")
    end
    
    it "should require the right authorized user" do
      login_as(:person)
      put :update, :id => @person
      response.should redirect_to(home_url)
    end
    
    # it "should change the password" do
    #   current_password = @person.unencrypted_password
    #   newpass = "dude"
    #   put :update, :id => @person,
    #                :person => { :verify_password => current_password,
    #                             :new_password => newpass,
    #                             :password_confirmation => newpass },
    #                :type => "password_edit"
    #   response.should redirect_to(person_url(@person))
    # end
  end
  
  describe "show" do
    render_views    
    
    #TODO: These belong in view specs
    # it "should display the edit link for current user" do
    #   login_as @person
    #   get :show, :id => @person
    #   response.should have_tag("a[href=?]", edit_person_path(@person))
    # end
    # 
    # it "should not display the edit link for other viewers" do
    #   login_as(:aaron)
    #   get :show, :id => @person
    #   response.should_not have_tag("a[href=?]", edit_person_path(@person))
    # end
    # 
    # it "should not display the edit link for non-logged-in viewers" do
    #   sign_out :person
    #   get :show, :id => @person
    #   response.should_not have_tag("a[href=?]", edit_person_path(@person))
    # end
    # 
    it "should not display a deactivated person" do
      @person.toggle!(:deactivated)
      get :show, :id => @person
      response.should redirect_to(home_url)
    end

    #TODO: These belong in view specs.
    # it "should display break up link if connected" do
    #   login_as(@person)
    #   @contact = Factory.build(:aaron)
    #   conn = Connection.connect(@person, @contact)
    #   get :show, :id => @contact.reload
    #   response.should have_tag("a[href=?]", connection_path(conn))
    # end
    # 
    # it "should not display break up link if not connected" do
    #   login_as(@person)
    #   @contact = Factory.build(:aaron)
    #   get :show, :id => @contact.reload
    #   response.should_not have_tag("a", :text => "Remove Connection")
    # end
  end
  
  private

    def create_person(options = {})
      person_hash = { :name => "Quire", :email => 'quire@foo.com',
                      :password => 'quux12', :password_confirmation => 'quux12' }
      post :create, :person => person_hash.merge(options)
      assigns(:person)
    end
end
