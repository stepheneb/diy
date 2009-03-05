class LearnerResourceBecomesRunnable < ActiveRecord::Migration
  def self.up
    rename_column("learners", :resource_id, :runnable_id)
    rename_column("learners", :resource_type, :runnable_type)
  end

  def self.down
    rename_column("learners", :runnable_id, :resource_id)
    rename_column("learners", :runnable_type, :resource_type)
  end
end
