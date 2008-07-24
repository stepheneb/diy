class AddSessions < ActiveRecord::Migration
  def self.up
    create_table "#{RAILS_DATABASE_PREFIX}sessions" do |t|
      t.column "session_id", :string
      t.column :data, :text
      t.column :updated_at, :datetime
    end
    add_index "#{RAILS_DATABASE_PREFIX}sessions", "session_id"
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}sessions"
  end
end
