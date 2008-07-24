class AddToModelsAndModelTypes < ActiveRecord::Migration
  def self.up
    change_column "#{RAILS_DATABASE_PREFIX}model_types", :description, :text
    change_column "#{RAILS_DATABASE_PREFIX}model_types", :credits, :text
    add_column "#{RAILS_DATABASE_PREFIX}models", :credits, :text
    add_column "#{RAILS_DATABASE_PREFIX}model_types", :authorable, :boolean
  end

  def self.down
    change_column "#{RAILS_DATABASE_PREFIX}model_types", :description
    change_column "#{RAILS_DATABASE_PREFIX}model_types", :credits
    remove_column "#{RAILS_DATABASE_PREFIX}models", :credits
    remove_column "#{RAILS_DATABASE_PREFIX}model_types", :authorable
  end
end
