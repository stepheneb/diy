class CreateUnits < ActiveRecord::Migration
  def self.up
    create_table "#{RAILS_DATABASE_PREFIX}units" do |t|
      t.string :name
      t.text :description
      t.text :notes
      t.date :created_on
      t.date :updated_on
    end
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}units"
  end
end
