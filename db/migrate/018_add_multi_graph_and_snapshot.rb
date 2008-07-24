class AddMultiGraphAndSnapshot < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata_probe_multi, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_probe_multi, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}models", :snapshot_active, :boolean
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata_probe_multi
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_probe_multi
    remove_column "#{RAILS_DATABASE_PREFIX}models", :snapshot_active
  end
end
