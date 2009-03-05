class AddDefaultAxesToCalibrations < ActiveRecord::Migration
  def self.up
     add_column "calibrations", :y_axis_min, :integer
     add_column "calibrations", :y_axis_max, :integer
     add_column "calibrations", :x_axis_min, :integer
     add_column "calibrations", :x_axis_max, :integer
  end

  def self.down
    remove_column "calibrations", :y_axis_min
    remove_column "calibrations", :y_axis_max
    remove_column "calibrations", :x_axis_min
    remove_column "calibrations", :x_axis_max
  end
end
