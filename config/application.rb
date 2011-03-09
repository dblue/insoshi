# Put this in config/application.rb
require File.expand_path('../boot', __FILE__)

module Insoshi
  class Application < Rails::Application
    config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )
    secret_file = File.join(RAILS_ROOT, "secret")
    if File.exist?(secret_file)
      secret = File.read(secret_file)
    else
      secret = ActiveSupport::SecureRandom.hex(64)
      File.open(secret_file, 'w') { |f| f.write(secret) }
    end
    config.action_controller.session = {
      :session_key => '_instant_social_session',
      :secret      => secret
    }
  end
end
