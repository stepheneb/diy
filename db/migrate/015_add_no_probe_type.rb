class AddNoProbeType < ActiveRecord::Migration
  def self.up
#    ProbeType.create(:name => "No Probe")
  end

  def self.down
#    ProbeType.find_by_name('No Probe').destroy
  end
end
