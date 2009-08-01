require File.dirname(__FILE__) + '/../spec_helper'

describe PreferencesHelper do
  
  include PreferencesHelper  
  
  it "should return the global preferences outside of test mode" do
    stub!(:test?).and_return(false)
    global_prefs.class.should == Preference
  end
end
