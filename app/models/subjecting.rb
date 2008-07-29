class Subjecting < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}subjectings"
  belongs_to :subject
  belongs_to :subjectable, :polymorphic => true
  validates_uniqueness_of :subjectable_id, :scope => [:subject_id, :subjectable_type]

  acts_as_replicatable

end
