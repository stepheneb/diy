class AddRolesUsers < ActiveRecord::Migration
  def self.up
    create_table "roles_users", :id => false, :force => true do |t|
      t.column "role_id", :integer
      t.column "user_id", :integer
    end
    add_column "roles", :position, :integer
    # the rest was moved to rake task
  end

  def self.down
    drop_table "roles_users"
    Role.delete_all
    remove_column "roles", :position
  end
end
