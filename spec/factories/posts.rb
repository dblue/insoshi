Factory.define :post do |p|
end

Factory.define :forum_post do |p|
  p.body "Some body text."
  p.association :person, :factory => :person
  p.association :topic
end

Factory.define :blog_post do |p|
  p.title "Blog Post"
  p.body "Some body text."
  p.association :person, :factory => :person
  p.association :blog
end
