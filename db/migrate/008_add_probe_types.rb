class AddProbeTypes < ActiveRecord::Migration
  def self.up
    say "replaced by Rake task: rake diy:create_default_probe_types"
  end
  
  def self.down
    ProbeType.find_all.each {|pt| pt.destroy}
  end
end







