class AddReportingModeToExternalOtrunkActivities < ActiveRecord::Migration
  def self.up
    add_column "external_otrunk_activities", :custom_reporting_mode, :string
  end

  def self.down
    remove_column "external_otrunk_activities", :custom_reporting_mode
  end
end
