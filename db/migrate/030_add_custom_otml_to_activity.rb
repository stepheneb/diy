class AddCustomOtmlToActivity < ActiveRecord::Migration
  def self.up
    add_column "activities", :custom_otml, :text, :limit => 16777215
  end

  def self.down
    remove_column "activities", :custom_otml
  end
end
