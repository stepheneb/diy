class ProbeType < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}probe_types"
  include Changeable
  include Replication

  has_many :activities

  before_create :generate_uuid

  belongs_to :user
  has_many :probes
  has_many :vendor_interfaces, :through => :probes
  
  has_many :calibrations

end
