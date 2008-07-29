class Calibration < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}calibrations"
  include Changeable
  
  acts_as_replicatable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  belongs_to :user
  belongs_to :physical_unit
  belongs_to :probe_type
  belongs_to :data_filter
  
  def self.new (options=nil)
    c = super(options)
    c.probe_type = ProbeType.find_by_name("Raw Voltage") unless c.probe_type
    c.data_filter = DataFilter.find(:first) unless c.data_filter
    c
  end
  
end
