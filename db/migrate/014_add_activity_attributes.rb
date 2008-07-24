class AddActivityAttributes < ActiveRecord::Migration
  def self.up
     add_column "#{RAILS_DATABASE_PREFIX}activities", :introduction_text_response, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :prediction_text_response, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :prediction_graph_response, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :proced_text_response, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :proced_drawing_response, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata_text_response, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :analysis_text_response, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :conclusion_text_response, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :further_text_response, :boolean
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :introduction_text_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :prediction_text_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :prediction_graph_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :proced_text_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :proced_drawing_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata_text_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :analysis_text_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :conclusion_text_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :further_text_response
  end
end
