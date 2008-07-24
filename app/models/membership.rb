class Membership < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}memberships"
  belongs_to :user
  belongs_to :group
  belongs_to :role
end
