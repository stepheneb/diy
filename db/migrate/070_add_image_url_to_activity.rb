class AddImageUrlToActivity < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :image_url, :string
  end

  def self.down
    remove_column  "#{RAILS_DATABASE_PREFIX}activities", :image_url
  end
end
