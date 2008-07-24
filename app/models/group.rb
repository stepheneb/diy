class Group < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}groups"
  has_many :memberships
  has_many :users, :through => :memberships
end
