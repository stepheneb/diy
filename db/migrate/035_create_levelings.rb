class CreateLevelings < ActiveRecord::Migration
  def self.up
    create_table "#{RAILS_DATABASE_PREFIX}levelings" do |t|
      t.integer :level_id
      t.integer :levelable_id
      t.string :levelable_type
    end
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}levelings"
  end
end
