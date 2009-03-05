class AddSecondPredictionToActivities < ActiveRecord::Migration
  def self.up
    add_column "activities", :collectdata_graph_response, :boolean
  end

  def self.down
    remove_column "activities", :collectdata_graph_response
  end
end
