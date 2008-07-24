class AddSdsAttributes < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :sds_offering_id, :integer
    add_column "#{RAILS_DATABASE_PREFIX}users", :sds_sail_user_id, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :sds_offering_id
    remove_column "#{RAILS_DATABASE_PREFIX}users", :sds_sail_user_id
  end
end
