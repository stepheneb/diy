class AddPreviousUserToUserHasManyResources < ActiveRecord::Migration
  def self.up
    User.reflect_on_all_associations(:has_many).collect do |assoc| 
      eval "add_column \"\#\{RAILS_DATABASE_PREFIX}#{assoc.name}\", :previous_user_id, :integer"
    end
    # which runs this:
    # add_column "#{RAILS_DATABASE_PREFIX}probe_types", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}activities", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}models", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}model_types", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}calibrations", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}learners", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}reports", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}vendor_interfaces", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}data_filters", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}memberships", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}probes", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}physical_units", :previous_user_id, :integer
    # add_column "#{RAILS_DATABASE_PREFIX}otrunk_report_templates", :previous_user_id, :integer
    # plus the versioned tables
    add_column "#{RAILS_DATABASE_PREFIX}activities_versions", :previous_user_id, :integer
    add_column "#{RAILS_DATABASE_PREFIX}models_versions", :previous_user_id, :integer
    add_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities_versions", :previous_user_id, :integer
    add_column "#{RAILS_DATABASE_PREFIX}otrunk_report_templates_versions", :previous_user_id, :integer   
  end

  def self.down
    User.reflect_on_all_associations(:has_many).collect do |assoc|
      eval "remove_column \"\#\{RAILS_DATABASE_PREFIX}#{assoc.name}\", :previous_user_id"
    end
    # which runs this:
    # remove_column "#{RAILS_DATABASE_PREFIX}probe_types", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}activities", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}models", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}model_types", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}calibrations", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}learners", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}reports", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}vendor_interfaces", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}data_filters", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}memberships", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}probes", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}physical_units", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}otrunk_report_templates", :previous_user_id
    # plus the versioned tables
    remove_column "#{RAILS_DATABASE_PREFIX}activities_versions", :previous_user_id
    # remove_column "#{RAILS_DATABASE_PREFIX}models_versions", :previous_user_id
    remove_column "#{RAILS_DATABASE_PREFIX}external_otrunk_activities_versions", :previous_user_id
    remove_column "#{RAILS_DATABASE_PREFIX}otrunk_report_templates_versions", :previous_user_id
  end
end
