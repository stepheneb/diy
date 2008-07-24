class CreateSubjectings < ActiveRecord::Migration
  def self.up
    create_table "#{RAILS_DATABASE_PREFIX}subjectings" do |t|
      t.integer :subject_id
      t.integer :subjectable_id
      t.string :subjectable_type
    end
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}subjectings"
  end
end
