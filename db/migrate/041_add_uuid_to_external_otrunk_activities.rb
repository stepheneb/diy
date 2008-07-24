class AddUuidToExternalOtrunkActivities < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :uuid, :string
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :uuid
  end
end
