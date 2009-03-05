class AddJavascriptDisableToUsers < ActiveRecord::Migration
  def self.up
    add_column "users", :disable_javascript, :boolean
  end

  def self.down
    remove_column "users", :disable_javascript
  end
end
