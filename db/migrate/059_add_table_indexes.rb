class AddTableIndexes < ActiveRecord::Migration
  def self.up
    add_index "roles", :id
    add_index "roles_users", :role_id
    add_index "roles_users", :user_id
    add_index "vendor_interfaces", :id
    add_index "learner_sessions", :learner_id
    
    add_index "learners", :runnable_id
    add_index "learners", :runnable_type
    add_index "activities", :user_id
    add_index "activities", :public
    add_index "activities", :id
    add_index "activities", :name
    
    add_index "activities", :model_id
    add_index "models", :user_id
    add_index "models", :public
    
    add_index "external_otrunk_activities", :user_id
    add_index "external_otrunk_activities", :public
    
    add_index "probe_types", :name
    
    add_index "models", :model_type_id
    
    add_index "model_types", :user_id
    
    add_index "learner_sessions", :created_at
  end

  def self.down
    remove_index "roles", :id
    remove_index "roles_users", :role_id
    remove_index "roles_users", :user_id
    remove_index "vendor_interfaces", :id
    remove_index "learner_sessions", :learner_id
    
    remove_index "learners", :runnable_id
    remove_index "learners", :runnable_type
    remove_index "activities", :user_id
    remove_index "activities", :public
    remove_index "activities", :id
    remove_index "activities", :name
    
    remove_index "activities", :model_id
    remove_index "models", :user_id
    remove_index "models", :public
    
    remove_index "external_otrunk_activities", :user_id
    remove_index "external_otrunk_activities", :public
    
    remove_index "probe_types", :name
    
    remove_index "models", :model_type_id
    
    remove_index "model_types", :user_id
    
    remove_index "learner_sessions", :created_at
  end
end
