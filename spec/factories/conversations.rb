Factory.define :conversation do |c|
  c.messages {|m| [Factory(:message)]}
end