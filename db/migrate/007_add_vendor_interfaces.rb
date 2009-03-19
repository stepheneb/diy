class AddVendorInterfaces < ActiveRecord::Migration
  def self.up
    say "replaced by rake task: 'rake diy:update_or_create_default_vendor_interfaces"
  end

  def self.down
    VendorInterface.find(:all).each {|vi| vi.destroy}
  end
end


