class AddAncestryToRunnables < ActiveRecord::Migration
  def self.up
    add_column "activities", :parent_id, :int
    add_column "models",:parent_id, :int
    add_column "external_otrunk_activities", :parent_id, :int
    
    add_column "activities", :parent_version, :int
    add_column "models",:parent_version, :int
    add_column "external_otrunk_activities", :parent_version, :int
  end

  def self.down
    remove_column "activities", :parent_id
    remove_column "models",:parent_id
    remove_column "external_otrunk_activities", :parent_id
    
    remove_column "activities", :parent_version
    remove_column "models",:parent_version
    remove_column "external_otrunk_activities", :parent_version
  end
end
