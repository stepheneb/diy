class SunflowerModel < ActiveRecord::Base

  def self.connection_possible?
    begin
      begin
        find(:first)
        true
      rescue Mysql::Error, SystemCallError,  ActiveRecord::AdapterNotSpecified, ActiveRecord::ActiveRecordError => e
        false
      end
    rescue NameError => e
      false
    end
  end

#  self.table_name_prefix = ""
  begin
    establish_connection :sunflower
  rescue ActiveRecord::AdapterNotSpecified, NameError => e
    false
  end

end
