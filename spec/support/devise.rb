RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include Devise::TestHelpers, :type => :view
  config.include Devise::TestHelpers, :type => :helper

  def login_as( person )
    if person.is_a?(Person)
      id = person.id
    elsif person.is_a?(Symbol)
      person = people(person)
      id = person.id
    elsif person.nil?
      id = nil
    end
    sign_in person
    person
  end
end
