class AddCustomOtmlToActivity < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :custom_otml, :text, :limit => 16777215
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :custom_otml
  end
end
