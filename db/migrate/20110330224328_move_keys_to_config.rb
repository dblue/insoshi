require 'fileutils'
class MoveKeysToConfig < ActiveRecord::Migration
  def self.key_dir
    File.join(Rails.root, 'config', 'keys')
  end
  
  def self.up
    FileUtils.mkdir key_dir unless File.exists? key_dir
    %w(identifier rsa_key rsa_key.pub secret uuid.state).each do |file|
      FileUtils.mv(file, key_dir) if File.exists? file
    end
  end

  def self.down
    %w(identifier rsa_key rsa_key.pub secret uuid.state).each do |file|
      src = File.join(key_dir, file)
      FileUtils.mv(src, Rails.root) if File.exists? src
    end
     adFileUtils.rmdir key_dir if File.exists? key_dir
  end
end
