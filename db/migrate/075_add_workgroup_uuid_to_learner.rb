class AddWorkgroupUuidToLearner < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}learners", :sds_workgroup_uuid, :text
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}learners", :sds_workgroup_uuid
  end
end
