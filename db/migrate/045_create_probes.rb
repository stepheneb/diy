class CreateProbes < ActiveRecord::Migration
  def self.up
    create_table "probes" do |t|
      t.column :user_id, :integer
      t.column :probe_type_id, :integer
      t.column :vendor_interface_id, :integer
      t.column :name, :string
      t.column :model_number, :string
      t.column :image, :blob
    end
  end

  def self.down
    drop_table "probes"
  end
end
