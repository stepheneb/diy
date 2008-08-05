class AddVendorInterfaces < ActiveRecord::Migration
  def self.up
    say "replaced by rake task: 'rake diy:create_default_vendor_interfaces"
  end

  def self.down
    VendorInterface.find_all.each {|vi| vi.destroy}
  end
end


