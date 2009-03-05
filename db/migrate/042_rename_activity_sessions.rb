class RenameActivitySessions < ActiveRecord::Migration
  def self.up
    remove_column("activity_sessions", :activity_id)
    rename_table("activity_sessions", "learner_sessions")
  end

  def self.down
    rename_table("learner_sessions", "activity_sessions")
    add_column("activity_sessions", :activity_id, :integer)
  end
end
