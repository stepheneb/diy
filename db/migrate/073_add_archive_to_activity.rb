class AddArchiveToActivity < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :archived, :boolean, {:default => false}
    add_column "#{RAILS_DATABASE_PREFIX}activities_versions", :archived, :boolean, {:default => false}
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :archived
    remove_column "#{RAILS_DATABASE_PREFIX}activities_versions", :archived
  end
end
