class AddNobundlesAttribute < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :nobundles, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}models", :nobundles, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :nobundles, :boolean
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :nobundles
    remove_column "#{RAILS_DATABASE_PREFIX}models", :nobundles
    remove_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :nobundles
  end
end
