require File.dirname(__FILE__) + '/../spec_helper'

describe PersonMailer do
  
  before(:each) do
    @preferences = Factory(:preference)
    @server = @preferences.server_name
    @domain = @preferences.domain
  end
  
  describe "message notification" do
    before(:each) do
      @message = Factory.create(:message)
      @email = PersonMailer.message_notification(@message)
    end

    it "should have the right sender" do
      @email.from.first.should == "message@#{@domain}"
    end

    it "should have the right recipient" do
      @email.to.first.should == @message.recipient.email
    end

    it "should have the right domain in the body" do
      @email.body.should =~ /#{@server}/
    end
  end

  describe "connection request" do
    before(:each) do
      @person  = Factory.create(:aaron)
      @contact = Factory.create(:person)
      Connection.request(@person, @contact)
      @connection = Connection.conn(@contact, @person)
      @email = PersonMailer.connection_request(@connection)
    end

    it "should have the right recipient" do
      @email.to.first.should == @contact.email
    end

    it "should have the right requester" do
      @email.body.should =~ /#{@person.name}/
    end

    it "should have a URL to the connection" do
      url = "http://#{@server}/connections/#{@connection.id}/edit"
      @email.body.should =~ /#{url}/
    end

    it "should have the right domain in the body" do
      @email.body.should =~ /#{@server}/
    end

    it "should have a link to the recipient's preferences" do
      prefs_url = "http://#{@server}"
      prefs_url += "/people/#{@contact.to_param}/edit"
      @email.body.should =~ /#{prefs_url}/
    end
  end

  describe "blog comment notification" do
    before(:each) do
      @comment = Factory(:blog_comment)
      @email = PersonMailer.blog_comment_notification(@comment)
      @recipient = @comment.commented_person
      @commenter = @comment.commenter
    end

    it "should have the right recipient" do
      @email.to.first.should == @recipient.email
    end

    it "should have the right commenter" do
      @email.body.should =~ /#{@commenter.name}/
    end

    it "should have a link to the comment" do
      url = "http://#{@server}"
      url += "/blogs/#{@comment.commentable.blog.to_param}"
      url += "/posts/#{@comment.commentable.to_param}"
      @email.body.should =~ /#{url}/
    end

    it "should have a link to the recipient's preferences" do
      prefs_url = "http://#{@server}/people/"
      prefs_url += "#{@recipient.to_param}/edit"
      @email.body.should =~ /#{prefs_url}/
    end
  end

  describe "wall comment notification" do
    before(:each) do
      @comment = Factory(:wall_comment)
      @email = PersonMailer.wall_comment_notification(@comment)
      @recipient = @comment.commented_person
      @commenter = @comment.commenter
    end

    it "should have the right recipient" do
      @email.to.first.should == @recipient.email
    end

    it "should have the right commenter" do
      @email.body.should =~ /#{@commenter.name}/
    end

    it "should have a link to the comment" do
      url = "http://#{@server}"
      url += "/people/#{@comment.commentable.to_param}#wall"
      @email.body.should =~ /#{url}/
    end

    it "should have a link to the recipient's preferences" do
      prefs_url = "http://#{@server}/people/#{@recipient.to_param}/edit"
      @email.body.should =~ /#{prefs_url}/
    end
  end

end