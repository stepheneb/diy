class AddNobundlesAttribute < ActiveRecord::Migration
  def self.up
    add_column "activities", :nobundles, :boolean
    add_column "models", :nobundles, :boolean
    add_column "external_otrunk_activities", :nobundles, :boolean
  end

  def self.down
    remove_column "activities", :nobundles
    remove_column "models", :nobundles
    remove_column "external_otrunk_activities", :nobundles
  end
end
