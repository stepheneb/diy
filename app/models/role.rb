class Role < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}roles"
#  has_and_belongs_to_many :users, options = {:join_table => "#{RAILS_DATABASE_PREFIX}roles_users", :foreign_key => "role_id"} 
  has_and_belongs_to_many :users, :join_table => "#{RAILS_DATABASE_PREFIX}roles_users", :foreign_key => "role_id" 
  acts_as_list
end
