class UnitActivity < ActiveRecord::Base
  set_table_name "unit_activities"

  belongs_to :activity 
  belongs_to :unit
  acts_as_list :scope => :unit 

  acts_as_replicatable

end
