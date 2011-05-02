Factory.define :comment do |c|
  c.body "This is a comment."
  c.association :commenter, :factory => :person
end

Factory.define :wall_comment, :parent => :comment do |c|
  c.association :commentable, :factory => :person
  c.commentable_type 'Person'
end

Factory.define :blog_comment, :parent => :comment do |c|
  c.body "This is a blog comment."
  c.association :commentable, :factory => :blog_post
  c.commentable_type 'BlogPost'
end

Factory.define :event_comment, :parent => :comment do |c|
  c.association :commentable, :factory => :event
  c.commentable_type 'Event'
end