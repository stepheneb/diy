class CreateOtrunkReportTemplates < ActiveRecord::Migration
  def self.up
    create_table "otrunk_report_templates" do |t|
      t.integer  "user_id", "parent_id"
      t.boolean  "public"
      t.string   "name"
      t.text     "description"
      t.text     "otml"
      t.integer  "sds_offering_id"
      t.string   "short_name"
      t.string   "uuid"
      t.string   "external_otml_url"
      t.boolean  "external_otml_always_update"
      t.datetime "external_otml_last_modified"
      t.string   "external_otml_filename"
      t.timestamps
    end
    # add version table
    OtrunkReportTemplate.create_versioned_table   
  end

  def self.down
    drop_table "otrunk_report_templates"
    # drop version table
    OtrunkReportTemplate.drop_versioned_table
  end
end
