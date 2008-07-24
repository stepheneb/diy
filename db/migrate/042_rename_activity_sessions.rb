class RenameActivitySessions < ActiveRecord::Migration
  def self.up
    remove_column("#{RAILS_DATABASE_PREFIX}activity_sessions", :activity_id)
    rename_table("#{RAILS_DATABASE_PREFIX}activity_sessions", "#{RAILS_DATABASE_PREFIX}learner_sessions")
  end

  def self.down
    rename_table("#{RAILS_DATABASE_PREFIX}learner_sessions", "#{RAILS_DATABASE_PREFIX}activity_sessions")
    add_column("#{RAILS_DATABASE_PREFIX}activity_sessions", :activity_id, :integer)
  end
end
