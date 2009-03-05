class Membership < ActiveRecord::Base
  set_table_name "memberships"
  
  acts_as_replicatable
  
  belongs_to :user
  belongs_to :group
  belongs_to :role
end
