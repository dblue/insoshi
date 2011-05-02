begin
  unless test?
    Preference.global_prefs = Preference.first
    if Preference.global_prefs.email_notifications?
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings = {
        :address    => Preference.global_prefs.smtp_server,
        :port       => 25,
        :domain     => Preference.global_prefs.domain
      }
    end
  end
rescue
  # Rescue from the error raised upon first migrating
  # (needed to bootstrap the preferences).
  nil
end