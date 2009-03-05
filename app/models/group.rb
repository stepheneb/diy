class Group < ActiveRecord::Base
  set_table_name "groups"
  
  acts_as_replicatable
  
  has_many :memberships
  has_many :users, :through => :memberships
end
