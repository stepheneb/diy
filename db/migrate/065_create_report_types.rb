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
    create_table "#{RAILS_DATABASE_PREFIX}report_types_reports", :id => false, :force => true do |t|
      t.integer "report_type_id"
      t.integer "report_id"
    end
  end

  def self.down
    drop_table "#{RAILS_DATABASE_PREFIX}report_types"
    drop_table "#{RAILS_DATABASE_PREFIX}report_types_reports"
  end
end
