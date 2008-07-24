class UnitActivity < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}unit_activities"

  belongs_to :activity 
  belongs_to :unit
  acts_as_list :scope => :unit 

end
