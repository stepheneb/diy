class AddVernierLabproInterface < ActiveRecord::Migration
  def self.up    
    VendorInterface.create(:name => "Vernier LabPro", :short_name => "vernier_labpro", :communication_protocol => 'usb', :description => "Vernier's LabPro interface works with many Vernier sensors.", :image => "SensorImages/VernierGoLink_sm.png")
  end

  def self.down
    VendorInterface.find_all.each {|vi| vi.destroy}
  end
end
