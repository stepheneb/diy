class AddSecondCareerStemToActivity < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :career_stem2, :text
    add_column "#{RAILS_DATABASE_PREFIX}activities", :career_stem2_text_response, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities_versions", :career_stem2, :text
    add_column "#{RAILS_DATABASE_PREFIX}activities_versions", :career_stem2_text_response, :boolean
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :career_stem2_text_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :career_stem2
    remove_column "#{RAILS_DATABASE_PREFIX}activities_versions", :career_stem2_text_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities_versions", :career_stem2
  end
end
