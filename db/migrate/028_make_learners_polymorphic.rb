class MakeLearnersPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column("learners", :activity_id, :resource_id)
    add_column "learners", :resource_type, :string
    execute "UPDATE `learners` set `resource_type` = 'Activity'"
  end

  def self.down
    rename_column("learners", :resource_id, :activity_id)
    remove_column "learners", :resource_type
  end
end
