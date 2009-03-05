class AddNameDescUserToReports < ActiveRecord::Migration
  def self.up
    add_column "reports", :name, :string
    add_column "reports", :description, :text
    add_column "reports", :user_id, :integer
  end

  def self.down
    remove_column "reports", :name
    remove_column "reports", :description
    remove_column "reports", :user_id
  end
end
