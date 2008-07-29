class AddUuids < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}calibrations", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}data_filters", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}groups", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}learners", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}learner_sessions", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}levels", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}levelings", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}memberships", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}model_types", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}physical_units", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}probes", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}probe_types", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}roles", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}subjects", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}subjectings", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}units", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}unit_activities", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}users", :uuid, :string
    add_column "#{RAILS_DATABASE_PREFIX}vendor_interfaces", :uuid, :string
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}calibrations", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}data_filters", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}groups", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}learners", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}learner_sessions", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}levels", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}levelings", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}memberships", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}model_types", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}physical_units", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}probes", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}probe_types", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}roles", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}subjects", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}subjectings", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}units", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}unit_activities", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}users", :uuid
    remove_column "#{RAILS_DATABASE_PREFIX}vendor_interfaces", :uuid
  end
end
