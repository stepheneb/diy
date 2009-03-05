class AddMoreDrawingResponses < ActiveRecord::Migration
  def self.up
    add_column "activities", :collectdata_drawing_response, :boolean
    add_column "activities", :collectdata2_drawing_response, :boolean
    add_column "activities", :collectdata3_drawing_response, :boolean
    add_column "activities", :further_drawing_response, :boolean
  end

  def self.down
    remove_column "activities", :collectdata_drawing_response
    remove_column "activities", :collectdata2_drawing_response
    remove_column "activities", :collectdata3_drawing_response
    remove_column "activities", :further_drawing_response
  end
end
