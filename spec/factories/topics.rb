Factory.define :topic do |t|
  t.forum {Factory(:forum)}
  t.person {Factory(:person)}
  t.name "Topic: foobar"
end