class ModelAndModelTypes < ActiveRecord::Migration
  def self.up
    create_table "model_types" do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :url, :string
      t.column :credits, :string
      t.column :otrunk_object_class, :string    
      t.column :otrunk_view_class, :string    
    end

    create_table "models" do |t|
      t.column :user_id, :integer
      t.column :model_type_id, :integer
      t.column :name, :string
      t.column :url, :string
      t.column :public, :boolean
      t.column :textile, :boolean
      t.column :description, :text
      t.column :instructions, :text
    end
  end

  def self.down
    drop_table "model_types"
    drop_table "models"
  end
end
