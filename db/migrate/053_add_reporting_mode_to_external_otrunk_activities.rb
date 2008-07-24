class AddReportingModeToExternalOtrunkActivities < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :custom_reporting_mode, :string
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :custom_reporting_mode
  end
end
