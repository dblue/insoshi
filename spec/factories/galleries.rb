Factory.define :gallery do |g|
  g.person {|g| g.association(:person)}
  g.title "Gallery Title"
  g.description "My photo gallery description"
end