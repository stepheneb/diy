class AddActivityIdToActivitySessions < ActiveRecord::Migration
  # pretty stupid to forget this ;-)
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activity_sessions", :activity_id, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activity_sessions", :activity_id
  end
end
