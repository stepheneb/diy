class CreateDeviceConfigs < ActiveRecord::Migration
  def self.up
    create_table "#{RAILS_DATABASE_PREFIX}device_configs" do |t|
      t.integer :vendor_interface_id
      t.string :config_string
      t.integer :user_id
      t.string :uuid
      
      t.timestamps
    end
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}device_configs"
  end
end
