Factory.define :forum do |f|
  f.sequence(:name) {|n| "Forum #{n}"}
  f.description "MyText"
end