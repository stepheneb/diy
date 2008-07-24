class CreateUnitActivities < ActiveRecord::Migration
  def self.up
    create_table "#{RAILS_DATABASE_PREFIX}unit_activities" do |t|
      t.integer :activity_id
      t.integer :unit_id
      t.integer :position
    end
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}unit_activities"
  end
end
