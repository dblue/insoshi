RSpec.configure do |config|
  def uploaded_file(filename, content_type = "image/png")
    t = Tempfile.new(filename)
    t.binmode
    path = File.join(Rails.root, "spec", "images", filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end).class_eval do
      alias local_path path
      define_method(:original_filename) {filename}
      define_method(:content_type) {content_type}
    end
    return t
  end

  def mock_photo(options = {})
    photo = mock_model(Photo)
    photo.stub!(:public_filename).and_return("photo.png")
    photo.stub!(:primary).and_return(options[:primary])
    photo.stub!(:primary?).and_return(photo.primary)
    photo
  end

  # Write response body to output file.
  # This can be very helpful when debugging specs that test HTML.
  def output_body(response)
    File.open("tmp/index.html", "w") { |f| f.write(response.body) }
  end

  # Make a user an admin.
  # All fixture people are not admins by default, to protect against mistakes.
  def admin!(person)
    person.admin = true
    person.save!
    person
  end

  # This is needed to get RSpec to understand link_to(..., person).
  def polymorphic_path(args)
    "http://a.fake.url"
  end

  def enable_email_notifications
    Preference.find(:first).update_attributes(:email_verifications => true)      
  end
end