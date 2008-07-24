class AddProbeTypes < ActiveRecord::Migration
  def self.up
    ProbeType.create(:name => "Temperature", :ptype => 0, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "degC", :min => 0, :max => 40, :period => 0.1)
    ProbeType.create(:name => "Light", :ptype => 2, :step_size => 0.1, :display_precision => 0, :port => 0, :unit => "lux", :min => 0, :max => 4000, :period => 0.1)
    ProbeType.create(:name => "Pressure", :ptype => 3, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "kPa", :min => 96, :max => 104, :period => 0.1)
    ProbeType.create(:name => "Voltage", :ptype => 4, :step_size => 0.1, :display_precision => -2, :port => 0, :unit => "V", :min => -10, :max => 10, :period => 0.1)
    ProbeType.create(:name => "Force (5N)", :ptype => 5, :step_size => 0.01, :display_precision => -2, :port => 0, :unit => "N", :min => -4, :max => 4, :period => 0.01)
    ProbeType.create(:name => "Force (50N)", :ptype => 5, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "N", :min => -40, :max => 40, :period => 0.01)
    ProbeType.create(:name => "Motion", :ptype => 13, :step_size => 0.1, :display_precision => -2, :port => 0, :unit => "m", :min => -4, :max => 4, :period => 0.1)
    ProbeType.create(:name => "Relative Humidity", :ptype => 7, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "percentage", :min => 10, :max => 90, :period => 0.1)
    ProbeType.create(:name => "CO2 Gas", :ptype => 18, :step_size => 20, :display_precision => 2, :port => 0, :unit => "ppm", :min => 0, :max => 500, :period => 1)
    ProbeType.create(:name => "Oxygen Gas", :ptype => 19, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "ppt", :min => 0, :max => 300, :period => 0.1)
    ProbeType.create(:name => "pH", :ptype => 20, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "pH", :min => 0, :max => 14, :period => 0.1)
    ProbeType.create(:name => "Salinity", :ptype => 21, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "ppt", :min => 0, :max => 50, :period => 0.1)
  end

  def self.down
    ProbeType.find_all.each {|pt| pt.destroy}
  end
end







