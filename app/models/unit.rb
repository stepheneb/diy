class Unit < ActiveRecord::Base
  set_table_name "units"

  has_many :unit_activities, :order => :position 
  has_many :activities, :through => :unit_activities

  acts_as_replicatable

end
