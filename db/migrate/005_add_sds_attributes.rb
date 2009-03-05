class AddSdsAttributes < ActiveRecord::Migration
  def self.up
    add_column "activities", :sds_offering_id, :integer
    add_column "users", :sds_sail_user_id, :integer
  end

  def self.down
    remove_column "activities", :sds_offering_id
    remove_column "users", :sds_sail_user_id
  end
end
