class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table "subjects" do |t|
      t.string :name
      t.text :description
      t.date :created_on
      t.date :updated_on
    end
  end

  def self.down
    drop_table "subjects"
  end
end
