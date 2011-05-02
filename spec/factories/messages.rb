Factory.define :message do |m|
  m.subject "New Message"
  m.content "This is the content for a message."
  m.sender { Factory(:person) }
  m.recipient { Factory(:person) }
end