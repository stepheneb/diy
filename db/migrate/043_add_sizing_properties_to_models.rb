class AddSizingPropertiesToModels < ActiveRecord::Migration
  def self.up
    add_column "model_types", :sizeable, :boolean
    add_column "models", :height, :integer
    add_column "models", :width, :integer
  end

  def self.down
    remove_column "model_types", :sizeable
    remove_column "models", :height
    remove_column "models", :width
  end
end
