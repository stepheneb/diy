class AddDefaultAxesToCalibrations < ActiveRecord::Migration
  def self.up
     add_column "#{RAILS_DATABASE_PREFIX}calibrations", :y_axis_min, :integer
     add_column "#{RAILS_DATABASE_PREFIX}calibrations", :y_axis_max, :integer
     add_column "#{RAILS_DATABASE_PREFIX}calibrations", :x_axis_min, :integer
     add_column "#{RAILS_DATABASE_PREFIX}calibrations", :x_axis_max, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}calibrations", :y_axis_min
    remove_column "#{RAILS_DATABASE_PREFIX}calibrations", :y_axis_max
    remove_column "#{RAILS_DATABASE_PREFIX}calibrations", :x_axis_min
    remove_column "#{RAILS_DATABASE_PREFIX}calibrations", :x_axis_max
  end
end
