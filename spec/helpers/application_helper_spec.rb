require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  include ApplicationHelper
  include ActionView::Helpers::UrlHelper

  describe "#app_name" do
    it "should return the default name by default" do
      global_prefs = mock_model(Preference,
                                :app_name => "")
      helper.stub!(:global_prefs).and_return(global_prefs)
      helper.app_name.should == "Insoshi"                                
    end

    it "should return the app name, if set" do
      global_prefs = mock_model(Preference,
                                :app_name => "test")
      helper.stub!(:global_prefs).and_return(global_prefs)
      helper.app_name.should == "test"                          
    end    
  end

  describe "#menu" do
    before(:each) do
      helper.stub!(:logged_in?).and_return(false)
      helper.stub!(:admin_view?).and_return(false)
      helper.stub!(:current_person).and_return(people(:quentin))
      global_prefs = mock_model(Preference, :about => "")
      helper.stub!(:global_prefs).and_return(global_prefs)
      Forum.stub(:count).and_return(1)
    end
    
    it "should only include Home (Dashboard) and People tabs by default" do
      helper.stub!(:logged_in?).and_return(false)
      helper.stub!(:admin_view?).and_return(false)
      helper.menu.collect{|mi| mi[:content] || nil}.sort.should == ["Dashboard", "People"]
    end
    
    it "should include an About tab if available" do
      global_prefs = mock_model(Preference, :about => "About us")
      helper.stub!(:global_prefs).and_return(global_prefs)
      helper.menu.collect{|mi| mi[:content] || nil}.should contain("About")
    end
    
    it "should include tabs for Home, Profile, Messages, People and Forum when logged in" do
      helper.stub!(:logged_in?).and_return(true)
      helper.stub!(:admin_view?).and_return(false)
      Forum.stub(:count).and_return(1)
      helper.menu.collect{|mi| mi[:content] || nil}.sort.should == ["Dashboard", "Forum", "Messages", "People", "Profile"]
    end
    
    it "should provide a Forums tag if there are multiple forums" do
      helper.stub!(:logged_in?).and_return(true)
      helper.stub!(:admin_view?).and_return(false)
      Forum.stub(:count).and_return(2)
      helper.menu.collect{|mi| mi[:content] || nil}.should contain("Forums")
    end
  end

  describe "#login_block" do
    it "should generate a login block with a password reminder if the app sends email" do
      global_prefs = mock_model(Preference,
                                :can_send_email? => true)
      helper.stub!(:global_prefs).and_return(global_prefs)
      helper.login_block.should =~ /Sign in/
      helper.login_block.should =~ /Sign up/
      helper.login_block.should =~ /I forgot my password/
    end
    
    it "should generate a loging block without a password reminder if the app does not send email" do
      global_prefs = mock_model(Preference,
                                :can_send_email? => false)
      helper.stub!(:global_prefs).and_return(global_prefs)
      helper.login_block.should =~ /Sign in/
      helper.login_block.should =~ /Sign up/
    end
  end

  describe "#admin_view?" do
    it "should return true if the user is an admin and is viewing the admin section" do
      mock_params = { :controller => "admin/preferences"}
      helper.stub!(:params).and_return(mock_params)
      helper.stub!(:admin?).and_return(true)
      helper.admin_view?.should be_true 
    end

    it "should return false if the user is an admin and is not viewing the admin section" do
      mock_params = { :controller => "preferences"}
      helper.stub!(:params).and_return(mock_params)
      helper.stub!(:admin?).and_return(true)

      # this evaluates to nil because (nil and true) is nil.
      helper.admin_view?.should be_nil
    end
    
    it "should return false if the user isn't an admin" do
      mock_params = { :controller => "admin/preferences"}
      helper.stub!(:params).and_return(mock_params)
      helper.stub!(:admin?).and_return(false)
      helper.admin_view?.should be_false
    end
  end

  describe "#admin?" do
    it "should return true if the user is logged in and is an admin" do
      person = mock_model(Person, :admin? => true)
      helper.stub!(:logged_in?).and_return(true)
      helper.stub!(:current_person).and_return(person)
      helper.admin?.should be_true
    end
    
    it "should return false if the user is not logged in" do
      person = mock_model(Person, :admin? => true)
      helper.stub!(:logged_in?).and_return(false)
      helper.stub!(:current_person).and_return(person)
      helper.admin?.should be_false
    end
    
    it "should return false if the user is not an admin" do
      person = mock_model(Person, :admin? => false)
      helper.stub!(:logged_in?).and_return(true)
      helper.stub!(:current_person).and_return(person)
      helper.admin?.should be_false
    end
  end

  describe "#set_focus_to" do
    it "should set the input focus for a specific id" do
      helper.set_focus_to(:valid_id).should =~ /valid_id/
    end
  end

  describe "#display" do
    it "should display text by sanitizing and formatting with no html_options" do
      helper.display("My **sample** text").should == 
        '<p>My <strong>sample</strong> text</p>'
    end
    
    it "should display text by santizing and formatting with html_options" do
      helper.display("My **sample** text", {:class => "special_class"}).should == 
        '<p class="special_class">My <strong>sample</strong> text</p>'
    end
    
    it "should do nothing to blank text" do
      helper.display(nil).should == ""
    end

    it "should rescue gracefully if Markdown throws an exception" do
      helper.should_receive(:format).and_raise "Markdown Error"
      helper.display("My **sample** text").should == "<p>My **sample** text</p>"
    end
  end
  
  describe "#format" do
    # NOTE: RDiscount and BlueCloth both define Markdown.
    # We should choose one (or the other) as a required gem, but
    # not check each time for both.
    before(:all) do
      old_Markdown = Markdown if defined?(Markdown)
    end
    
    it "should format text using Markdown if available" do
      helper.should_receive(:markdown?).and_return(true)
      helper.display("My **sample** text").should == "<p>My <strong>sample</strong> text</p>"
    end
    
    it "should use plain text if there is no Markdown" do
      helper.should_receive(:markdown?).and_return(false)
      helper.display("<p>My **sample** text</p>").should == "<p>My **sample** text</p>"
    end
  
    it "should add a paragraph tag if needed and if there is no Markdown" do
      helper.should_receive(:markdown?).and_return(false)
      helper.display("My **sample** text").should == "<p>My **sample** text</p>"
    end
            
    after(:all) do
      Markdown = old_Markdown if defined?(old_Markdown)
    end
  end

  describe "#email_link" do
    before(:each) do
      @person = people(:quentin)
    end
    
    it "should generate an email link for a person" do
      results = email_link(@person)
      results.should =~ /quentin/
      results.should =~ /Send Message/
    end
    
    it "should use a reply message path for replies" do
      reply_to = people(:admin)
      results = email_link(@person, {:replying_to => reply_to})
      results.should =~ /admin/
      results.should =~ /Send Reply/
    end
        
    it "should not use an image if specified" do
      results = email_link(@person, {:use_image => false})
      results.should_not =~ /img/
    end
  end

  describe "#formatting_note" do
    it "should provide a formatting hint if Markdown is supported" do
      helper.should_receive(:markdown?).and_return(true)
      helper.formatting_note.should =~ /markdown/i
    end
    it "should provide a formatting hint if Markdown is not supported" do
      helper.should_receive(:markdown?).and_return(false)
      helper.formatting_note.should =~ /HTML/
    end
  end

  describe "#format(text)" do
  end

end