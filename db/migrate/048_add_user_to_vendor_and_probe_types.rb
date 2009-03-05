class AddUserToVendorAndProbeTypes < ActiveRecord::Migration
  def self.up
    add_column "vendor_interfaces", :user_id, :integer
    add_column "probe_types", :user_id, :integer
  end

  def self.down
    remove_column "vendor_interfaces", :user_id
    remove_column "probe_types", :user_id
  end
end
