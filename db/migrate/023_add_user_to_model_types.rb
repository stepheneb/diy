class AddUserToModelTypes < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}model_types", :user_id, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}model_types", :user_id
  end
end
