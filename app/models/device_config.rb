class DeviceConfig < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}device_configs"
  include Changeable
  acts_as_replicatable
  
  belongs_to :user
  belongs_to :vendor_interface
  has_many :calibrations
end
