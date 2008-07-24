class AddUserToVendorAndProbeTypes < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}vendor_interfaces", :user_id, :integer
    add_column "#{RAILS_DATABASE_PREFIX}probe_types", :user_id, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}vendor_interfaces", :user_id
    remove_column "#{RAILS_DATABASE_PREFIX}probe_types", :user_id
  end
end
