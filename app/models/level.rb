class Level < ActiveRecord::Base
  set_table_name "levels"
  has_many :levelings
  has_many :leveled_activities, :through => :levelings, :source => :levelable, :source_type => 'Activity'
  has_many :leveled_models, :through => :levelings, :source => :levelable, :source_type => 'Model'
  has_many :leveled__external_otrunk_activities, :through => :levelings, :source => :levelable, :source_type => 'ExternalOtrunkActivity'
  
  acts_as_replicatable
  
end
