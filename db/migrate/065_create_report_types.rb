class CreateReportTypes < ActiveRecord::Migration
  def self.up
    create_table "#{RAILS_DATABASE_PREFIX}report_types" do |t|
      t.string "uuid"
      t.string "uri"
      t.string "name"
      t.boolean "limit_to_one", :default => false
      t.integer "user_id"
      t.timestamps
    end
    
    add_index "#{RAILS_DATABASE_PREFIX}report_types", :uri
    add_index "#{RAILS_DATABASE_PREFIX}report_types", :name
    add_index "#{RAILS_DATABASE_PREFIX}report_types", :user_id
    
    create_table "#{RAILS_DATABASE_PREFIX}report_types_reports", :id => false, :force => true do |t|
      t.integer "report_type_id"
      t.integer "report_id"
    end
    
    add_index "#{RAILS_DATABASE_PREFIX}report_types_reports", :report_type_id
    add_index "#{RAILS_DATABASE_PREFIX}report_types_reports", :report_id
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}report_types"
    drop_table "#{RAILS_DATABASE_PREFIX}report_types_reports"
  end
end
