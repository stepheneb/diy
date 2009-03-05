class AddExternalUrlToExternalOtrunkActivities < ActiveRecord::Migration
  def self.up
    add_column "external_otrunk_activities", :external_otml_url, :string
    add_column "external_otrunk_activities", :external_otml_always_update, :boolean
    add_column "external_otrunk_activities", :external_otml_last_modified, :datetime
    add_column "external_otrunk_activities", :external_otml_filename, :string
  end

  def self.down
    remove_column "external_otrunk_activities", :external_otml_url
    remove_column "external_otrunk_activities", :external_otml_always_update
    remove_column "external_otrunk_activities", :external_otml_last_modified
    remove_column "external_otrunk_activities", :external_otml_filename
  end
end
