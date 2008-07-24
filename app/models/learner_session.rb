class LearnerSession < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}learner_sessions"
  belongs_to :learner
end
