class AddCalibrationAttributesToActivity < ActiveRecord::Migration
  def self.up
     add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata1_calibration_active, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata1_calibration_id, :integer
     add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_calibration_active, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_calibration_id, :integer
     add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_calibration_active, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_calibration_id, :integer
     add_column "#{RAILS_DATABASE_PREFIX}activities", :furtherprobe_calibration_active, :boolean
     add_column "#{RAILS_DATABASE_PREFIX}activities", :furtherprobe_calibration_id, :integer
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata1_calibration_active
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata1_calibration_id
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_calibration_active 
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata2_calibration_id
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_calibration_active 
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :collectdata3_calibration_id
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :furtherprobe_calibration_active 
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :furtherprobe_calibration_id
  end
end
