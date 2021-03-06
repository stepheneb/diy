class AddAnotherContentSection < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3, :text    
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_text_response, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_probe_active, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_model_active, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_probe_multi, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_probetype_id, :integer
    add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_model_id, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3  
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_text_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_probe_active
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_model_active
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_probe_multi
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_probetype_id
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_model_id
  end
end
