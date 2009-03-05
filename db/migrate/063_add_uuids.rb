class AddUuids < ActiveRecord::Migration
  def self.up
    add_column "calibrations", :uuid, :string
    add_column "data_filters", :uuid, :string
    add_column "groups", :uuid, :string
    add_column "learners", :uuid, :string
    add_column "learner_sessions", :uuid, :string
    add_column "levels", :uuid, :string
    add_column "levelings", :uuid, :string
    add_column "memberships", :uuid, :string
    add_column "model_types", :uuid, :string
    add_column "physical_units", :uuid, :string
    add_column "probes", :uuid, :string
    add_column "probe_types", :uuid, :string
    add_column "roles", :uuid, :string
    add_column "subjects", :uuid, :string
    add_column "subjectings", :uuid, :string
    add_column "units", :uuid, :string
    add_column "unit_activities", :uuid, :string
    add_column "users", :uuid, :string
    add_column "vendor_interfaces", :uuid, :string
  end

  def self.down
    remove_column "calibrations", :uuid
    remove_column "data_filters", :uuid
    remove_column "groups", :uuid
    remove_column "learners", :uuid
    remove_column "learner_sessions", :uuid
    remove_column "levels", :uuid
    remove_column "levelings", :uuid
    remove_column "memberships", :uuid
    remove_column "model_types", :uuid
    remove_column "physical_units", :uuid
    remove_column "probes", :uuid
    remove_column "probe_types", :uuid
    remove_column "roles", :uuid
    remove_column "subjects", :uuid
    remove_column "subjectings", :uuid
    remove_column "units", :uuid
    remove_column "unit_activities", :uuid
    remove_column "users", :uuid
    remove_column "vendor_interfaces", :uuid
  end
end
