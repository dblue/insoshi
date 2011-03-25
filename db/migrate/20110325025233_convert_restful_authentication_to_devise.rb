class ConvertRestfulAuthenticationToDevise < ActiveRecord::Migration
  def self.up
    
    # database authenticable
    rename_column :people, :crypted_password, :encrypted_password
    change_column :people, :encrypted_password, :string, :default => "", :null => false
    add_column :people, :password_salt, :string, :default => "", :null => false
    change_column :people, :email, :string, :default => "", :null => false
    
    # registerable
    add_column :people, :confirmation_token, :string
    add_column :people, :confirmed_at, :datetime
    add_column :people, :confirmation_sent_at, :datetime

    # recoverable
    add_column :people, :reset_password_token, :string
    
    # rememberable
    # there is already a remember token
    rename_column :people, :remember_token_expires_at, :remember_created_at
    
    # trackable
    add_column :people, :sign_in_count, :integer, :default => 0
    add_column :people, :current_sign_in_at, :datetime
    rename_column :people, :last_logged_in_at, :last_sign_in_at
    add_column :people, :last_sign_in_ip, :string
    add_column :people, :current_sign_in_ip, :string

    # lockable
    add_column :people, :failed_attempts, :integer, :default => 0
    add_column :people, :unlock_token, :string
    add_column :people, :locked_at, :datetime
    
    # validatable
    add_column :people, :validation_token, :string

    # indices
    # add_index :users, :email,                :unique => true
    add_index :people, :reset_password_token, :unique => true
    add_index :people, :confirmation_token,   :unique => true
    add_index :people, :unlock_token,         :unique => true
  end

  def self.down
    # database authenticable
    change_column :people, :email, :string
    # remove_column :people, :password_salt
    rename_column :people, :encrypted_password, :crypted_password
    change_column :people, :crypted_password, :string
    
    # registerable
    remove_column :people, :confirmation_sent_at
    remove_column :people, :confirmed_at
    remove_column :people, :confirmation_token

    # recoverable
    remove_column :people, :reset_password_token
    
    # rememberable
    rename_column :people, :remember_created_at, :remember_token_expires_at
    
    # trackable
    remove_column :people, :current_sign_in_ip
    remove_column :people, :last_sign_in_ip
    remove_column :people, :sign_in_count
    remove_column :people, :current_sign_in_at
    rename_column :people, :last_sign_in_at, :last_logged_in_at

    # lockable
    remove_column :people, :locked_at
    remove_column :people, :unlock_token
    remove_column :people, :failed_attempts
    
    # validatable
    remove_column :people, :validation_token

    # indicies
    remove_index :people, :reset_password_token
    remove_index :people, :confirmation_token
    remove_index :people, :unlock_token
  end
end
