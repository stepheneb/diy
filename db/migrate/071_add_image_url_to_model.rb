class AddImageUrlToModel < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}models", :image_url, :string
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}models", :image_url
  end
end
