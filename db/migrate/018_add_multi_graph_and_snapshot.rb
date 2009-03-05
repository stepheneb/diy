class AddMultiGraphAndSnapshot < ActiveRecord::Migration
  def self.up
    add_column "activities", :collectdata_probe_multi, :boolean
    add_column "activities", :collectdata2_probe_multi, :boolean
    add_column "models", :snapshot_active, :boolean
  end

  def self.down
    remove_column "activities", :collectdata_probe_multi
    remove_column "activities", :collectdata2_probe_multi
    remove_column "models", :snapshot_active
  end
end
