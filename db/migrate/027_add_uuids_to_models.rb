class AddUuidsToModels < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}models", :uuid, :string
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}models", :uuid
  end
end
