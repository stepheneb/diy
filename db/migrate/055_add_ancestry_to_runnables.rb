class AddAncestryToRunnables < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :parent_id, :int
    add_column "#{RAILS_DATABASE_PREFIX}models",:parent_id, :int
    add_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :parent_id, :int
    
    add_column "#{RAILS_DATABASE_PREFIX}activities", :parent_version, :int
    add_column "#{RAILS_DATABASE_PREFIX}models",:parent_version, :int
    add_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :parent_version, :int
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :parent_id
    remove_column "#{RAILS_DATABASE_PREFIX}models",:parent_id
    remove_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :parent_id
    
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :parent_version
    remove_column "#{RAILS_DATABASE_PREFIX}models",:parent_version
    remove_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :parent_version
  end
end
