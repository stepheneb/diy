class Report < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}reports"
  include Changeable
  
  acts_as_replicatable
  
  self.extend SearchableModel

  belongs_to :user
  belongs_to :reportable, :polymorphic => true  
  belongs_to :otrunk_report_template
  has_and_belongs_to_many :report_types, :join_table => "#{RAILS_DATABASE_PREFIX}report_types_reports"
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  include OtrunkSystem
  include SdsRunnable

  validates_presence_of :name
  validates_uniqueness_of :name

  def short_name
    self.otrunk_report_template.short_name + '_for_' + self.reportable.short_name
  end

  def self.reportable_serialize_token
    ":"
  end

  def self.serialize_reportable(activity)
   return [activity.class.name.to_s,activity.id].join(reportable_serialize_token)
  end
  
  def reportable_s
    if self.reportable
      return Report.serialize_reportable(self.reportable)
    end
    return nil
  end

  def reportable_from_s(string)
    type,id= string.split(Report.reportable_serialize_token)
    
    if id.to_i > 0 && reportable_types.index(type.constantize)
      self.reportable=type.constantize.find(id.to_i)  
    else
      logger.error("Error: bad reportable: #{string}")
    end
    return self.reportable
  end

  def reportable_s=(rep)
    if rep.is_a? String
      self.reportable_from_s(rep)
    end
  end
  
  protected
  
  def validate
    # validate any report_types which have limit_to_one = true
    self.report_types.select{|rt| rt.limit_to_one}.each do |rep_type|
      reports = self.reportable.reports.select{|rep| (rep != self && rep.report_types.include?(rep_type))}
      if reports.size > 0
        errors.add("report_type", "Limited report type (#{rep_type.id}: #{rep_type.name}) already in use in #{reports.collect{|r| "#{r.id}: #{r.name}"}.join(", ")}")
      end
    end
  end

  def reportable_types
    [Activity,ExternalOtrunkActivity]
  end
end
