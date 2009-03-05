class LearnerSession < ActiveRecord::Base
  set_table_name "learner_sessions"
  belongs_to :learner
  
  acts_as_replicatable
  
end
