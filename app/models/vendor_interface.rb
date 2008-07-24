class VendorInterface < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}vendor_interfaces"
  include Changeable

  has_many :users
  belongs_to :author, :class_name => 'User'
  has_many :probes
  has_many :probe_types, :through => :probes
  
  @@device_id_hash = {
    "vernier_goio" => "10",
    "dataharvest_easysense_q" => "41",
    "fourier_ecolog" => "30",
    "pasco_airlink" => "61",
    "pasco_sw500" => "60",
    "ti_cbl2" => "20",
    "pseudo_interface" => "0"
  }

  def VendorInterface.deviceid(shortname)
    @@device_id_hash[shortname]
  end
 
end

# For more info see:
# https://confluence.concord.org/display/TMS/OT+Schema
# http://source.concord.org/sensor/apidocs/index-all.html
# http://source.concord.org/sensor/apidocs/constant-values.html#org.concord.sensor.device.impl.DeviceID.PSEUDO_DEVICE
#
# currently defined list of: vendor_interface.short_name
# "vernier_goio"
# "dataharvest_easysense_q"
# "fourier_ecolog"
# "pasco_airlink"
# "pasco_sw500"
# "ti_cbl2"
# "pseudo_interface"
#
# org.concord.sensor.device.impl.DeviceID
# CCPROBE_VERSION_0	70
# CCPROBE_VERSION_1	71
# CCPROBE_VERSION_2	72
# COACH	80
# DATA_HARVEST_ADVANCED	41
# DATA_HARVEST_CF	45
# DATA_HARVEST_QADVANCED	42
# DATA_HARVEST_USB	40
# FOURIER	30
# IMAGIWORKS_SD	55
# IMAGIWORKS_SERIAL	50
# PASCO_AIRLINK	61
# PASCO_SERIAL	60
# PSEUDO_DEVICE	0
# TI_CONNECT	20
# VERNIER_GO_LINK	10
