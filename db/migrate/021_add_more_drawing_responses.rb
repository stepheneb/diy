class AddMoreDrawingResponses < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata_drawing_response, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_drawing_response, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_drawing_response, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :further_drawing_response, :boolean
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata_drawing_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_drawing_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_drawing_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :further_drawing_response
  end
end
