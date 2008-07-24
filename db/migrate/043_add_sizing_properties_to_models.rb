class AddSizingPropertiesToModels < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}model_types", :sizeable, :boolean
    add_column "#{RAILS_DATABASE_PREFIX}models", :height, :integer
    add_column "#{RAILS_DATABASE_PREFIX}models", :width, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}model_types", :sizeable
    remove_column "#{RAILS_DATABASE_PREFIX}models", :height
    remove_column "#{RAILS_DATABASE_PREFIX}models", :width
  end
end
