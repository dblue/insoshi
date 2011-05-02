Factory.define :event do |e|
  e.title "Some Event"
  e.description "This is an event description."
  e.person { Factory(:person)} 
  e.start_time "2008-08-19 19:38:49"
  e.end_time "2008-08-19 19:38:49"
  e.reminder false
  e.privacy 1 # public
end