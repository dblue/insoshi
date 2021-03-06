class PersonMailer < ActionMailer::Base
  extend PreferencesHelper
  
  def domain
    @domain ||= Preference.global_prefs.domain
  end
  
  def server
    @server_name ||= Preference.global_prefs.server_name
  end
  
  def password_reminder(person)
    @person = person
    mail(
      :from => "Password reminder <password-reminder@#{domain}>",
      :to => person.email, 
      :subject => formatted_subject("Password reminder")
    )
  end
  
  def message_notification(message)
    @server = server
    @message = message
    @preferences_note = preferences_note(message.recipient)
    mail(
      :from => "Message notification <message@#{domain}>",
      :to => message.recipient.email,
      :subject => formatted_subject("New message")
    )
  end
  
  def connection_request(connection)
    @server = server
    @connection = connection
    @url = edit_connection_path(connection)
    @preferences_note = preferences_note(connection.person)    
    mail(
      :from => "Contact request <connection@#{domain}>",
      :to => connection.person.email,
      :subject => formatted_subject("Contact request from #{connection.contact.name}")
    )
  end
  
  def blog_comment_notification(comment)
    @server = server
    @comment = comment
    @url = blog_post_path(comment.commentable.blog, comment.commentable)
    @preferences_note = preferences_note(comment.commented_person)    
    mail(
      :from => "Comment notification <comment@#{domain}>",
      :to => comment.commented_person.email,
      :subject => formatted_subject("New blog comment")
    )
  end
  
  def wall_comment_notification(comment)
    @server = server
    @comment = comment
    @url = person_path(comment.commentable, :anchor => "wall")
    @preferences_note = preferences_note(comment.commented_person)
    mail(
      :from => "Comment notification <comment@#{domain}>",
      :to => comment.commented_person.email,
      :subject => formatted_subject("New wall comment")
    )
  end
  
  def email_verification(ev)
    @server = server
    @code = ev.code
    mail(
      :from => "Email verification <email@#{domain}>",
      :to => ev.person.email,
      :subject => formatted_subject("Email verification")
    )
  end
  
  private
  
    # Prepend the application name to subjects if present in preferences.
    def formatted_subject(text)
      name = Preference.global_prefs.app_name
      label = name.blank? ? "" : "[#{name}] "
      "#{label}#{text}"
    end
  
    def preferences_note(person)
      %(To change your email notification preferences, visit http://#{server}/people/#{person.to_param}/edit#email_prefs)
    end
end
