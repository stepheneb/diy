class AddGroupsAndLearners < ActiveRecord::Migration
  def self.up    
    create_table "#{RAILS_DATABASE_PREFIX}groups", :force => true  do |t|
      t.column :public, :boolean
      t.column :key, :string
      t.column :textile, :boolean
      t.column :name, :string
      t.column :description, :string
      t.column :introduction, :text
    end

    create_table "#{RAILS_DATABASE_PREFIX}memberships", :force => true  do |t|
        t.column :group_id, :integer
        t.column :user_id, :integer
        t.column :role_id, :integer
    end

    create_table "#{RAILS_DATABASE_PREFIX}learners", :force => true  do |t|
        t.column :user_id, :integer
        t.column :activity_id, :integer
        t.column :sds_workgroup_id, :integer
    end

    create_table "#{RAILS_DATABASE_PREFIX}activity_sessions", :force => true  do |t|
        t.column :learner_id, :integer
        t.column :created_at, :timestamp
    end
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}groups"
    drop_table "#{RAILS_DATABASE_PREFIX}memberships"
    drop_table "#{RAILS_DATABASE_PREFIX}learners"
    drop_table "#{RAILS_DATABASE_PREFIX}activity_sessions"
  end
end
