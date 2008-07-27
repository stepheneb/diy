class AddPublicAttributeToReports < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}reports", :public, :boolean
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}reports", :public
  end
end
