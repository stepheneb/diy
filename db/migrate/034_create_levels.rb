class CreateLevels < ActiveRecord::Migration
  def self.up
    create_table "levels" do |t|      
      t.string :name
      t.text :description
      t.date :created_on
      t.date :updated_on
    end
  end

  def self.down
    drop_table "levels"
  end
end
