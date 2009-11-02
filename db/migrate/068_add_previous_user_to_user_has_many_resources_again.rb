class AddPreviousUserToUserHasManyResourcesAgain < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}report_types", :previous_user_id, :integer
    add_column "#{RAILS_DATABASE_PREFIX}device_configs", :previous_user_id, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}report_types", :previous_user_id
    remove_column "#{RAILS_DATABASE_PREFIX}device_configs", :previous_user_id
  end
end
