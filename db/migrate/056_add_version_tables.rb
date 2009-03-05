class AddVersionTables < ActiveRecord::Migration
  def self.up
    # Don't need to add version tables since *.create_versioned_table will create it for us
    
    # make sure the models have up-to-date fields even if multiple migrations have run
    Activity.reset_column_information
    Model.reset_column_information
    ExternalOtrunkActivity.reset_column_information

    # add version tables
    Activity.create_versioned_table
    Model.create_versioned_table
    ExternalOtrunkActivity.create_versioned_table
  end

  def self.down
    #remove version from Runnables
    # only necessary because *.drop_versioned_table doesn't delete it for us
     remove_column "activities", :version
     remove_column "models",:version
     remove_column "external_otrunk_activities", :version
    
    # remove version tables
    Activity.drop_versioned_table
    Model.drop_versioned_table
    ExternalOtrunkActivity.drop_versioned_table
  end
end
