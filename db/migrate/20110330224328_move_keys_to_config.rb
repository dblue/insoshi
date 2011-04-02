require 'fileutils'
class MoveKeysToConfig < ActiveRecord::Migration
  def key_dir
    key_dir = File.join(Rails.root, 'config', 'keys')
  end
  
  def self.up
    File.mkdir key_dir
    %w(identifier rsa_key rsa_key.pub secret uuid.state).each do |file|
      FileUtils.mv(file, key_dir) if File.exists? file
    end
  end

  def self.down
    %w(identifier rsa_key rsa_key.pub secret uuid.state).each do |file|
      src = File.join(key_dir, file)
      FileUtils.mv(src, Rails.root) if File.exists? src
    end
  end
end
