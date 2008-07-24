class AddNameDescUserToReports < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}reports", :name, :string
    add_column "#{RAILS_DATABASE_PREFIX}reports", :description, :text
    add_column "#{RAILS_DATABASE_PREFIX}reports", :user_id, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}reports", :name
    remove_column "#{RAILS_DATABASE_PREFIX}reports", :description
    remove_column "#{RAILS_DATABASE_PREFIX}reports", :user_id
  end
end
