class AddTables < ActiveRecord::Migration
  def self.up
    create_table "#{RAILS_DATABASE_PREFIX}activities" do |t|
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
    
    create_table "#{RAILS_DATABASE_PREFIX}probe_types" do |t|
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
    
    create_table "#{RAILS_DATABASE_PREFIX}vendor_interfaces" do |t|
      t.column :name, :string
      t.column :short_name, :string
      t.column :description, :text
      t.column :communication_protocol, :string
      t.column :image, :string
    end

    add_column "#{RAILS_DATABASE_PREFIX}users", :first_name, :string
    add_column "#{RAILS_DATABASE_PREFIX}users", :last_name, :string
    add_column "#{RAILS_DATABASE_PREFIX}users", :vendor_interface_id, :integer
    add_column "#{RAILS_DATABASE_PREFIX}users", :password_hash, :string

    create_table "#{RAILS_DATABASE_PREFIX}roles", :force => true do |t|
      t.column :title, :string
    end
  end
  
  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}users", :first_name
    remove_column "#{RAILS_DATABASE_PREFIX}users", :last_name
    remove_column "#{RAILS_DATABASE_PREFIX}users", :vendor_interface_id
    remove_column "#{RAILS_DATABASE_PREFIX}users", :password_hash
    drop_table "#{RAILS_DATABASE_PREFIX}activities"
    drop_table "#{RAILS_DATABASE_PREFIX}probe_types"
    drop_table "#{RAILS_DATABASE_PREFIX}roles"
    drop_table "#{RAILS_DATABASE_PREFIX}vendor_interfaces"
  end
end


