class AddVernierLabproInterface < ActiveRecord::Migration
  def self.up
    say "replaced by rake task: 'rake diy:create_default_vendor_interfaces"
  end

  def self.down
    VendorInterface.find_by_name("Vernier LabPro").destroy
  end
end
