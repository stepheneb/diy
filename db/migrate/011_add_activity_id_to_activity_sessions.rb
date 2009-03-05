class AddActivityIdToActivitySessions < ActiveRecord::Migration
  # pretty stupid to forget this ;-)
  def self.up
    add_column "activity_sessions", :activity_id, :integer
  end

  def self.down
    remove_column "activity_sessions", :activity_id
  end
end
