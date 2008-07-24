class Unit < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}units"

  has_many :unit_activities, :order => :position 
  has_many :activities, :through => :unit_activities

end
