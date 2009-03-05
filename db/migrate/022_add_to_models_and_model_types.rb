class AddToModelsAndModelTypes < ActiveRecord::Migration
  def self.up
    change_column "model_types", :description, :text
    change_column "model_types", :credits, :text
    add_column "models", :credits, :text
    add_column "model_types", :authorable, :boolean
  end

  def self.down
    change_column "model_types", :description
    change_column "model_types", :credits
    remove_column "models", :credits
    remove_column "model_types", :authorable
  end
end
