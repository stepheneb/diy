class AddTableIndexes < ActiveRecord::Migration
  def self.up
    add_index "#{RAILS_DATABASE_PREFIX}roles", :id
    add_index "#{RAILS_DATABASE_PREFIX}roles_users", :role_id
    add_index "#{RAILS_DATABASE_PREFIX}roles_users", :user_id
    add_index "#{RAILS_DATABASE_PREFIX}vendor_interfaces", :id
    add_index "#{RAILS_DATABASE_PREFIX}learner_sessions", :learner_id
    
    add_index "#{RAILS_DATABASE_PREFIX}learners", :runnable_id
    add_index "#{RAILS_DATABASE_PREFIX}learners", :runnable_type
    add_index "#{RAILS_DATABASE_PREFIX}activities", :user_id
    add_index "#{RAILS_DATABASE_PREFIX}activities", :public
    add_index "#{RAILS_DATABASE_PREFIX}activities", :id
    add_index "#{RAILS_DATABASE_PREFIX}activities", :name
    
    add_index "#{RAILS_DATABASE_PREFIX}activities", :model_id
    add_index "#{RAILS_DATABASE_PREFIX}models", :user_id
    add_index "#{RAILS_DATABASE_PREFIX}models", :public
    
    add_index "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :user_id
    add_index "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :public
    
    add_index "#{RAILS_DATABASE_PREFIX}probe_types", :name
    
    add_index "#{RAILS_DATABASE_PREFIX}models", :model_type_id
    
    add_index "#{RAILS_DATABASE_PREFIX}model_types", :user_id
    
    add_index "#{RAILS_DATABASE_PREFIX}learner_sessions", :created_at
  end

  def self.down
    remove_index "#{RAILS_DATABASE_PREFIX}roles", :id
    remove_index "#{RAILS_DATABASE_PREFIX}roles_users", :role_id
    remove_index "#{RAILS_DATABASE_PREFIX}roles_users", :user_id
    remove_index "#{RAILS_DATABASE_PREFIX}vendor_interfaces", :id
    remove_index "#{RAILS_DATABASE_PREFIX}learner_sessions", :learner_id
    
    remove_index "#{RAILS_DATABASE_PREFIX}learners", :runnable_id
    remove_index "#{RAILS_DATABASE_PREFIX}learners", :runnable_type
    remove_index "#{RAILS_DATABASE_PREFIX}activities", :user_id
    remove_index "#{RAILS_DATABASE_PREFIX}activities", :public
    remove_index "#{RAILS_DATABASE_PREFIX}activities", :id
    remove_index "#{RAILS_DATABASE_PREFIX}activities", :name
    
    remove_index "#{RAILS_DATABASE_PREFIX}activities", :model_id
    remove_index "#{RAILS_DATABASE_PREFIX}models", :user_id
    remove_index "#{RAILS_DATABASE_PREFIX}models", :public
    
    remove_index "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :user_id
    remove_index "#{RAILS_DATABASE_PREFIX}external_otrunk_activities", :public
    
    remove_index "#{RAILS_DATABASE_PREFIX}probe_types", :name
    
    remove_index "#{RAILS_DATABASE_PREFIX}models", :model_type_id
    
    remove_index "#{RAILS_DATABASE_PREFIX}model_types", :user_id
    
    remove_index "#{RAILS_DATABASE_PREFIX}learner_sessions", :created_at
  end
end
