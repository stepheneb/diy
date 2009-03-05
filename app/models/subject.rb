class Subject < ActiveRecord::Base
  set_table_name "subjects"
  has_many :subjectings
  has_many :subjected_activities, :through => :subjectings, :source => :subjectable, :source_type => 'Activity'
  has_many :subjected_models, :through => :subjectings, :source => :subjectable, :source_type => 'Model'
  has_many :subjected_external_otrunk_activities, :through => :subjectings, :source => :subjectable, :source_type => 'ExternalOtrunkActivity'

  acts_as_replicatable
end
