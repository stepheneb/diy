class CreateCalibrations < ActiveRecord::Migration
  def self.up
    create_table "calibrations" do |t|
      t.column :data_filter_id, :integer
      t.column :probe_type_id, :integer
      t.column :default_calibration, :boolean
      t.column :physical_unit_id, :integer
      t.column :user_id, :integer
      t.column :name, :string
      t.column :description, :text
      t.column :k0, :float
      t.column :k1, :float
      t.column :k2, :float
      t.column :k3, :float
    end
  end

  def self.down
    drop_table "calibrations"
  end
end
