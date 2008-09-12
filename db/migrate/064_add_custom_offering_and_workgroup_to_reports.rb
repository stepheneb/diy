class AddCustomOfferingAndWorkgroupToReports < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}reports", :custom_offering_id, :integer
    add_column "#{RAILS_DATABASE_PREFIX}reports", :custom_workgroup_id, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}reports", :custom_offering_id
    remove_column "#{RAILS_DATABASE_PREFIX}reports", :custom_workgroup_id
  end
end
