module ActivitiesHelper
  include OtmlHelper
  
  def get_object_for_attribute(obj, attr)
    attr.gsub(/_id$/,'') =~ /([^_]+)$/
    klass = class_from_string($1)
    if klass == 'Runnable'
      klass = obj.class.to_s
    end
    o = nil
    begin
      o = eval("#{klass}.find(obj.#{attr})")
    rescue Exception
      puts "error in eval: #{klass}.find(obj.#{attr})"
    end
    return o
  end
  
  def class_from_string(str)
    case str
    when 'model'
      'Model'
    when 'activity'
      'Activity'
    when 'type'
      'ProbeType'
    when 'probetype'
      'ProbeType'
    when 'user'
      'User'
    when 'calibration'
      'Calibration'
    when 'parent'
      'Runnable'
    when 'offering'
      nil
    end
  end
end
