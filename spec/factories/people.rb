Factory.define :person do |p|
  p.sequence(:name)  { |n| "John Doe No. #{n}" }
  p.sequence(:email) { |n| "johndoe-#{n}@bluekudzu.org" }
  p.description "I am John Doe, test user extraordinaire."
  p.password "foobar"
  p.admin false
  p.deactivated false
  p.confirmed_at {Time.now.to_s :db}
  p.wall_comments_count 0
end

Factory.define :admin, :parent => :person do |p|
  p.name "Jack Admin"
  p.email "admin@bluekudzu.org"
  p.description "The all-powerful admin."
  p.password "foobar"
  p.admin true
end

Factory.define :quentin, :parent => :person do |p|
  p.name "Quentin"
  p.email "quentin@example.com"
  p.description "I am Quentin."
end

Factory.define :aaron, :parent => :person do |p|
  p.name "Aaron"
  p.email "aaron@example.com"
  p.description "I am Aaron."
end

Factory.define :kelly, :parent => :person do |p|
  p.name "Kelly"
  p.email "kelly@example.com"
  p.description "I am Kelly."
end

Factory.define :deactivated, :parent => :person do |p|
  p.deactivated true
end
