class AddUuidToExternalOtrunkActivities < ActiveRecord::Migration
  def self.up
    add_column "external_otrunk_activities", :uuid, :string
  end

  def self.down
    remove_column "external_otrunk_activities", :uuid
  end
end
