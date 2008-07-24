class AddJavascriptDisableToUsers < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}users", :disable_javascript, :boolean
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}users", :disable_javascript
  end
end
