class Leveling < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}levelings"
  belongs_to :level
  belongs_to :levelable, :polymorphic => true
  validates_uniqueness_of :levelable_id, :scope => [:level_id, :levelable_type]
  
  acts_as_replicatable
  
end
