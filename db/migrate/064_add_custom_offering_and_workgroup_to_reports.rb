class AddCustomOfferingAndWorkgroupToReports < ActiveRecord::Migration
  def self.up
    add_column "reports", :custom_offering_id, :integer
    add_column "reports", :custom_workgroup_id, :integer
  end

  def self.down
    remove_column "reports", :custom_offering_id
    remove_column "reports", :custom_workgroup_id
  end
end
