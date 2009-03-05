class AddPreviousUserToUserHasManyResources < ActiveRecord::Migration
  def self.up
    User.reflect_on_all_associations(:has_many).collect do |assoc| 
      eval "add_column \"\#\{RAILS_DATABASE_PREFIX}#{assoc.name}\", :previous_user_id, :integer"
    end
    # which runs this:
    # add_column "probe_types", :previous_user_id, :integer
    # add_column "activities", :previous_user_id, :integer
    # add_column "models", :previous_user_id, :integer
    # add_column "external_otrunk_activities", :previous_user_id, :integer
    # add_column "model_types", :previous_user_id, :integer
    # add_column "calibrations", :previous_user_id, :integer
    # add_column "learners", :previous_user_id, :integer
    # add_column "reports", :previous_user_id, :integer
    # add_column "vendor_interfaces", :previous_user_id, :integer
    # add_column "data_filters", :previous_user_id, :integer
    # add_column "memberships", :previous_user_id, :integer
    # add_column "probes", :previous_user_id, :integer
    # add_column "physical_units", :previous_user_id, :integer
    # add_column "otrunk_report_templates", :previous_user_id, :integer
    # plus the versioned tables
    add_column "activities_versions", :previous_user_id, :integer
    add_column "models_versions", :previous_user_id, :integer
    add_column "external_otrunk_activities_versions", :previous_user_id, :integer
    add_column "otrunk_report_templates_versions", :previous_user_id, :integer   
  end

  def self.down
    User.reflect_on_all_associations(:has_many).collect do |assoc|
      eval "remove_column \"\#\{RAILS_DATABASE_PREFIX}#{assoc.name}\", :previous_user_id"
    end
    # which runs this:
    # remove_column "probe_types", :previous_user_id
    # remove_column "activities", :previous_user_id
    # remove_column "models", :previous_user_id
    # remove_column "external_otrunk_activities", :previous_user_id
    # remove_column "model_types", :previous_user_id
    # remove_column "calibrations", :previous_user_id
    # remove_column "learners", :previous_user_id
    # remove_column "reports", :previous_user_id
    # remove_column "vendor_interfaces", :previous_user_id
    # remove_column "data_filters", :previous_user_id
    # remove_column "memberships", :previous_user_id
    # remove_column "probes", :previous_user_id
    # remove_column "physical_units", :previous_user_id
    # remove_column "otrunk_report_templates", :previous_user_id
    # plus the versioned tables
    remove_column "activities_versions", :previous_user_id
    # remove_column "models_versions", :previous_user_id
    remove_column "external_otrunk_activities_versions", :previous_user_id
    remove_column "otrunk_report_templates_versions", :previous_user_id
  end
end
