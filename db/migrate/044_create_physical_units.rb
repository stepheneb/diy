class CreatePhysicalUnits < ActiveRecord::Migration
  def self.up
    create_table "#{RAILS_DATABASE_PREFIX}physical_units" do |t|
      t.column :user_id, :integer
      t.column :name, :string
      t.column :quantity, :string
      t.column :unit_symbol, :string
      t.column :unit_symbol_text, :string
      t.column :description, :text
      t.column :si, :boolean
      t.column :base_unit, :boolean
    end
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}physical_units"
  end
end
