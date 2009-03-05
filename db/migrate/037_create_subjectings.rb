class CreateSubjectings < ActiveRecord::Migration
  def self.up
    create_table "subjectings" do |t|
      t.integer :subject_id
      t.integer :subjectable_id
      t.string :subjectable_type
    end
  end

  def self.down
    drop_table "subjectings"
  end
end
