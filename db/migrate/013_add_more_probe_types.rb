class AddMoreProbeTypes < ActiveRecord::Migration
  def self.up
    say "replaced by Rake task: rake diy:create_default_probe_types"
  end

  def self.down
    ProbeType.find_by_name("Raw Data").destroy
    ProbeType.find_by_name("Raw Voltage").destroy
  end
end
