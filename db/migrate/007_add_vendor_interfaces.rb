class AddVendorInterfaces < ActiveRecord::Migration
  def self.up    
    VendorInterface.create(:name => "Fourier Ecolog", :short_name => "fourier_ecolog", :communication_protocol => 'usb', :description => "The Fourier EcoLog has several built-in sensors, can read external Fourier sensors, and communicates via usb.", :image => "SensorImages/EcoLogXL_sm.png")
    VendorInterface.create(:name => "Data Harvest Easysense Q", :short_name => "dataharvest_easysense_q", :communication_protocol => 'usb', :description => "The Data Harvest EasySense Q works with all the Data Harvest sensors and communicates via usb.", :image => "SensorImages/EasysenseQ_sm.png")
    VendorInterface.create(:name => "Pasco Science Workshop 500", :short_name => "pasco_sw500", :communication_protocol => 'serial', :description => "The Pasco Science Workshop 500 has four input ports for connecting older Pasco sensors and communicates to your computer via a serial port.", :image => "SensorImages/Pasco500_sm.png")
    VendorInterface.create(:name => "Pasco Airlink SI", :short_name => "pasco_airlink", :communication_protocol => 'bluetooth', :description => "The Pasco AirLink Si uses PASPORT sensors and communicates to your computer via Bluetooth wireless networking.", :image => "SensorImages/pasportairlinksi_sm.png")
    VendorInterface.create(:name => "Texas Instruments CBL2", :short_name => "ti_cbl2", :communication_protocol => 'usb', :description => "The Texas Instruments CBL2 works with TI sensors and communicates via usb.", :image => "SensorImages/ti_cbl2.jpg")
    VendorInterface.create(:name => "Vernier Go! Link", :short_name => "vernier_goio", :communication_protocol => 'usb', :description => "Vernier's usb Go!Link interface works with many Vernier sensors. The Go! Temp and Go!Motion sensors have a Go!Link interfaces integrated into the sensor.", :image => "SensorImages/VernierGoLink_sm.png")
    VendorInterface.create(:name => "Simulated Data", :short_name => "pseudo_interface", :communication_protocol => 'simulated', :description => "Use the Simulated Data interface when you have no probeware to attach to your computer but you stillwant to test your activity.", :image => "SensorImages/psuedo_interface.jpg")  
  end

  def self.down
    VendorInterface.find_all.each {|vi| vi.destroy}
  end
end


