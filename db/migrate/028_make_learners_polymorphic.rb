class MakeLearnersPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column("#{RAILS_DATABASE_PREFIX}learners", :activity_id, :resource_id)
    add_column "#{RAILS_DATABASE_PREFIX}learners", :resource_type, :string
    execute "UPDATE `#{RAILS_DATABASE_PREFIX}learners` set `resource_type` = 'Activity'"
  end

  def self.down
    rename_column("#{RAILS_DATABASE_PREFIX}learners", :resource_id, :activity_id)
    remove_column "#{RAILS_DATABASE_PREFIX}learners", :resource_type
  end
end
