class AddUserToModelTypes < ActiveRecord::Migration
  def self.up
    add_column "model_types", :user_id, :integer
  end

  def self.down
    remove_column "model_types", :user_id
  end
end
