class CreateReports < ActiveRecord::Migration
  def self.up
    create_table "reports" do |t|
      t.integer "otrunk_report_template_id", "reportable_id"
      t.string "reportable_type"
      t.string "uuid"
      t.timestamps
    end
  end

  def self.down
    drop_table "reports"
  end
end
