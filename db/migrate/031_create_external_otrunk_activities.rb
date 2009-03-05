class CreateExternalOtrunkActivities < ActiveRecord::Migration
  def self.up
    create_table "external_otrunk_activities" do |t|
      t.column :user_id, :integer
      t.column :public, :boolean
      t.column :name, :string
      t.column :description, :text
      t.column :otml, :text, :limit => 16777215
      t.column :sds_offering_id, :integer
      t.column :short_name, :string
    end
  end

  def self.down
    drop_table "external_otrunk_activities"
  end
end
