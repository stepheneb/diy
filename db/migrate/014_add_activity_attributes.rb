class AddActivityAttributes < ActiveRecord::Migration
  def self.up
     add_column "activities", :introduction_text_response, :boolean
     add_column "activities", :prediction_text_response, :boolean
     add_column "activities", :prediction_graph_response, :boolean
     add_column "activities", :proced_text_response, :boolean
     add_column "activities", :proced_drawing_response, :boolean
     add_column "activities", :collectdata_text_response, :boolean
     add_column "activities", :analysis_text_response, :boolean
     add_column "activities", :conclusion_text_response, :boolean
     add_column "activities", :further_text_response, :boolean
  end

  def self.down
    remove_column "activities", :introduction_text_response
    remove_column "activities", :prediction_text_response
    remove_column "activities", :prediction_graph_response
    remove_column "activities", :proced_text_response
    remove_column "activities", :proced_drawing_response
    remove_column "activities", :collectdata_text_response
    remove_column "activities", :analysis_text_response
    remove_column "activities", :conclusion_text_response
    remove_column "activities", :further_text_response
  end
end
