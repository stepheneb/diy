class LearnerResourceBecomesRunnable < ActiveRecord::Migration
  def self.up
    rename_column("#{RAILS_DATABASE_PREFIX}learners", :resource_id, :runnable_id)
    rename_column("#{RAILS_DATABASE_PREFIX}learners", :resource_type, :runnable_type)
  end

  def self.down
    rename_column("#{RAILS_DATABASE_PREFIX}learners", :runnable_id, :resource_id)
    rename_column("#{RAILS_DATABASE_PREFIX}learners", :runnable_type, :resource_type)
  end
end
