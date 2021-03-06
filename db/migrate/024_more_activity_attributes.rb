class MoreActivityAttributes < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :introduction_drawing_response, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :prediction_drawing_response, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :analysis_drawing_response, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :conclusion_drawing_response, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :further_probe_active, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :further_probetype_id, :integer  
    add_column "#{RAILS_DATABASE_PREFIX}activities", :further_probe_multi, :boolean  
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :introduction_drawing_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :prediction_drawing_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :analysis_drawing_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :conclusion_drawing_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :further_probe_active
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :further_probetype_id    
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :further_probe_multi  
  end
end
