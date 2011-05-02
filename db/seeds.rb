# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
if Preference.count == 0
  puts "Creating initial preference data."
  Preference.create(:domain => 'example.com',
                    :server_name => 'server.example.net',
                    :app_name => 'Example',
                    :smtp_server => 'smtp.example.com',
                    :email_notifications => true,
                    :email_verifications => true,
                    :analytics => '')
end
