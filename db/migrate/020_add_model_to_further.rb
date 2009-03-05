class AddModelToFurther < ActiveRecord::Migration
  def self.up
    add_column "activities", :further_model_active, :boolean
    add_column "activities", :further_model_id, :integer
  end

  def self.down
    remove_column "activities", :further_model_active
    remove_column "activities", :further_model_id
  end
end
