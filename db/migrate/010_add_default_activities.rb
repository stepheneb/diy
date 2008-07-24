class AddDefaultActivities < ActiveRecord::Migration
  def self.up
    puts "Create default activities using the rake tasks:\n  rake diy:create_activity_mixing_water\n  rake diy:create_activity_greenhouse_effect\n"
  end

  def self.down
  end
end


