class AddSectionToActivity < ActiveRecord::Migration
  def self.up
      add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2, :text    
      add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_text_response, :boolean
      add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata_probe_active, :boolean
      add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata_model_active, :boolean
      add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_probe_active, :boolean
      add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_model_active, :boolean
      add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_probetype_id, :integer
      add_column "#{RAILS_DATABASE_PREFIX}activities", :model_id, :integer
      add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_model_id, :integer
      Activity.find(:all).each {|a| a.update_attribute(:collectdata_probe_active, true) }
    end

    def self.down
      remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2
      remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_text_response
      remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata_probe_active
      remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata_model_active
      remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_probe_active
      remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_model_active
      remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_probetype_id
      remove_column "#{RAILS_DATABASE_PREFIX}activities", :model_id
      remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_model_id
    end
end
