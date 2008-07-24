class Probe < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}probes"
  include Changeable
  
  belongs_to :user
  belongs_to :probe_type
  belongs_to :vendor_interface
  
end
