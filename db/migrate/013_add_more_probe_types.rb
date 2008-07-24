class AddMoreProbeTypes < ActiveRecord::Migration
  def self.up
    ProbeType.create(:name => "Raw Data", :ptype => 22, :step_size => 1, :display_precision => 0, :port => 0, :unit => "raw", :min => -10000, :max => 10000, :period => 0.1)
    ProbeType.create(:name => "Raw Voltage", :ptype => 23, :step_size => 0.01, :display_precision => -2, :port => 0, :unit => "V", :min => -1, :max => 10, :period => 0.1)
  end

  def self.down
    ProbeType.find_by_name("Raw Data").destroy
    ProbeType.find_by_name("Raw Voltage").destroy
  end
end
