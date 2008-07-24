class AddExternalUrlToExternalOtrunkActivities < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :external_otml_url, :string
    add_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :external_otml_always_update, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :external_otml_last_modified, :datetime
    add_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :external_otml_filename, :string
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :external_otml_url
    remove_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :external_otml_always_update
    remove_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :external_otml_last_modified
    remove_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :external_otml_filename
  end
end
