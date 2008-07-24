class AddSdsAttributesToModels < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}models", :sds_offering_id, :integer
    add_column "#{RAILS_DATABASE_PREFIX}models", :short_name, :string
    Model.reset_column_information
    Model.find(:all).each { |m| m.generate_uuid; m.save }
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}models", :sds_offering_id
    remove_column "#{RAILS_DATABASE_PREFIX}models", :short_name
  end
end
