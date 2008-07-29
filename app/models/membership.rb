class Membership < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}memberships"
  
  acts_as_replicatable
  
  belongs_to :user
  belongs_to :group
  belongs_to :role
end
