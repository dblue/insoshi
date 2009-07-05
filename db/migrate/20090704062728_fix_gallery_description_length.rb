class FixGalleryDescriptionLength < ActiveRecord::Migration
  def self.up
    change_column :galleries, :description, :text, :length => 1000
  end

  def self.down
    change_column :galleries, :description, :string
  end
end
