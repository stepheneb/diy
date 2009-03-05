class Role < ActiveRecord::Base
  set_table_name "roles"
  
  acts_as_replicatable
  
#  has_and_belongs_to_many :users, options = {:join_table => "roles_users", :foreign_key => "role_id"} 
  has_and_belongs_to_many :users, :join_table => "roles_users", :foreign_key => "role_id" 
  acts_as_list
end
