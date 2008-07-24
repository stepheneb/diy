class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table "#{RAILS_DATABASE_PREFIX}subjects" do |t|
      t.string :name
      t.text :description
      t.date :created_on
      t.date :updated_on
    end
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}subjects"
  end
end
