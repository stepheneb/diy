class AddDeviceIdToVendorInterface < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}vendor_interfaces", :device_id, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}vendor_interfaces", :device_id
  end
end
