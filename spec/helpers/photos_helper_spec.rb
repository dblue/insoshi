require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhotosHelper do
  include PhotosHelper
  
  it "should generate an id based on filename" do
    examples = [['Testname', 'Testname'],
                ['No Spaces', 'NoSpaces'],
                ['No.Periods', 'No_Periods'],
                ['No Spaces and No.Periods', 'NoSpacesandNo_Periods']]
    examples.each do |label, correct|
      @photo = mock_model(Photo, :label_from_filename => label)
      photo_id(@photo).should == correct
    end
  end
end
