# Helpers added to this module are available in both controllers and views.
module SharedHelper

  def current_person?(person)
    person_signed_in? and person == current_person
  end
  
  # Return true if a person is connected to (or is) the current person
  def connected_to?(person)
    current_person?(person) or Connection.connected?(person, current_person)
  end
end
