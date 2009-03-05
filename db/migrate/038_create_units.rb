class CreateUnits < ActiveRecord::Migration
  def self.up
    create_table "units" do |t|
      t.string :name
      t.text :description
      t.text :notes
      t.date :created_on
      t.date :updated_on
    end
  end

  def self.down
    drop_table "units"
  end
end
