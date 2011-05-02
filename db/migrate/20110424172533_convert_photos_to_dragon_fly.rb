class ConvertPhotosToDragonFly < ActiveRecord::Migration
  
  class Photo < ActiveRecord::Base; end;
  class Thumbnail < ActiveRecord::Base; end;
  
  def self.up
    add_column :photos, :photo_uid, :string
    add_column :photos, :photo_ext, :string
    
    rename_column :photos, :filename,     :photo_name
    rename_column :photos, :content_type, :photo_mime_type
    rename_column :photos, :size,         :photo_size
    rename_column :photos, :width,        :photo_width
    rename_column :photos, :height,       :photo_height

    Photo.all.each do |p|
      p.update_attributes(:photo_uid => ("%08d" % p.id).scan(/..../).join('/') << '/' << p.photo_name,
                          :photo_ext => p.photo_name.split('.').last)  
    end
    
    Photo.delete_all('parent_id is not null')
    remove_column :photos, :parent_id                      
  end
  
  def self.down
    remove_column :photos, :photo_uid
    remove_column :photos, :photo_ext

    rename_column :photos, :photo_name,      :filename
    rename_column :photos, :photo_mime_type, :content_type
    rename_column :photos, :photo_size,      :size
    rename_column :photos, :photo_width,     :width
    rename_column :photos, :photo_height,    :height

    add_column :photos, :parent_id,  :integer
  end
end
