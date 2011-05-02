Factory.define :photo do |p|
  p.person {Factory(:person)}
  p.gallery {Factory(:gallery)}
  p.photo {uploaded_file('rails.png', "image/png")}
end