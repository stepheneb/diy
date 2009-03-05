class MoreActivityAttributes < ActiveRecord::Migration
  def self.up
    add_column "activities", :introduction_drawing_response, :boolean
    add_column "activities", :prediction_drawing_response, :boolean
    add_column "activities", :analysis_drawing_response, :boolean
    add_column "activities", :conclusion_drawing_response, :boolean
    add_column "activities", :further_probe_active, :boolean
    add_column "activities", :further_probetype_id, :integer  
    add_column "activities", :further_probe_multi, :boolean  
  end

  def self.down
    remove_column "activities", :introduction_drawing_response
    remove_column "activities", :prediction_drawing_response
    remove_column "activities", :analysis_drawing_response
    remove_column "activities", :conclusion_drawing_response
    remove_column "activities", :further_probe_active
    remove_column "activities", :further_probetype_id    
    remove_column "activities", :further_probe_multi  
  end
end
