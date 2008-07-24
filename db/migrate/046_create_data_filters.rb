class CreateDataFilters < ActiveRecord::Migration
  def self.up
    create_table "#{RAILS_DATABASE_PREFIX}data_filters" do |t|
      t.column :user_id, :integer
      t.column :name, :string
      t.column :description, :text
      t.column :otrunk_object_class, :string
      t.column :k0_active, :boolean
      t.column :k1_active, :boolean
      t.column :k2_active, :boolean
      t.column :k3_active, :boolean
    end
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}data_filters"
  end
end
