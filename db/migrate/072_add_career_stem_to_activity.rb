class AddCareerStemToActivity < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :career_stem, :text
    add_column "#{RAILS_DATABASE_PREFIX}activities", :career_stem_text_response, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}activities_versions", :career_stem, :text
    add_column "#{RAILS_DATABASE_PREFIX}activities_versions", :career_stem_text_response, :boolean
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :career_stem_text_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :career_stem
    remove_column "#{RAILS_DATABASE_PREFIX}activities_versions", :career_stem_text_response
    remove_column "#{RAILS_DATABASE_PREFIX}activities_versions", :career_stem
  end
end
