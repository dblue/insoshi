class CreateLocalKeys < ActiveRecord::Migration
  include Crypto
  def self.up
    # Identifier for the tracker
    identifier = File.join(Rails.root, "config", "keys", "identifier")
    File.open(identifier, "w") do |f|
      f.write UUID.new
    end unless File.exist?(identifier)
    # RSA keys for user authentication
    Crypto.create_keys File.join(Rails.root, "config", "keys", "rsa_key")
  end

  def self.down
  end
end
