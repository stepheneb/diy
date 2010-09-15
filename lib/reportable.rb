module Reportable
  ##
  ## Called when a class extends this module:
  ##
  def self.included(clazz)
    clazz.class_eval do
      after_save   :create_reportable
      after_update :create_reportable
    end
  end
 
  def default_template_url
    template_url_prop = "#{self.class.name.underscore}_report_template_url".to_sym
    return APP_PROPERTIES[template_url_prop]
  end
  
  def default_template_name
    template_name_prop = "#{self.class.name.underscore}_report_template_name".to_sym
    return APP_PROPERTIES[template_name_prop] || "default #{self.class.name.humanize} template"
  end

  def create_reportable
    if self.public && self.default_template_url
      found = Report.find_by_reportable_id(self.id)
      unless found
        r = Report.create( {
          :name => "#{self.name} report",
          :description => "#{self.name} report",
          :public => true,
          :reportable => self,
          :user => self.user,
          :otrunk_report_template => OtrunkReportTemplate.find_or_create_by_url(default_template_url,default_template_name)
        })
      end
    end
  end  

end
