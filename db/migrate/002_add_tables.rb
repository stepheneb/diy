class AddTables < ActiveRecord::Migration
  def self.up
    create_table "activities" do |t|
      t.column :user_id, :integer
      t.column :uuid, :string
      t.column :public, :boolean
      t.column :draft, :boolean
      t.column :short_name, :string
      t.column :textile, :boolean
      t.column :name, :string
      t.column :description, :string
      t.column :introduction, :text
      t.column :standards, :text
      t.column :probe_type_id, :integer
      t.column :materials, :text
      t.column :safety, :text
      t.column :proced, :text
      t.column :predict, :text
      t.column :collectdata, :text
      t.column :analysis, :text
      t.column :conclusion, :text
      t.column :further, :text
    end
    
    create_table "probe_types" do |t|
      t.column :name, :string
      t.column :ptype, :integer
      t.column :step_size, :float
      t.column :display_precision, :integer
      t.column :port, :integer
      t.column :unit, :string
      t.column :min, :float
      t.column :max, :float
      t.column :period, :float
    end
    
    create_table "vendor_interfaces" do |t|
      t.column :name, :string
      t.column :short_name, :string
      t.column :description, :text
      t.column :communication_protocol, :string
      t.column :image, :string
    end

    add_column "users", :first_name, :string
    add_column "users", :last_name, :string
    add_column "users", :vendor_interface_id, :integer
    add_column "users", :password_hash, :string

    create_table "roles", :force => true do |t|
      t.column :title, :string
    end
  end
  
  def self.down
    remove_column "users", :first_name
    remove_column "users", :last_name
    remove_column "users", :vendor_interface_id
    remove_column "users", :password_hash
    drop_table "activities"
    drop_table "probe_types"
    drop_table "roles"
    drop_table "vendor_interfaces"
  end
end


