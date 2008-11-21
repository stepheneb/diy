class Report < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}reports"
  include Changeable
  
  acts_as_replicatable
  
  self.extend SearchableModel

  belongs_to :user
  belongs_to :reportable, :polymorphic => true  
  belongs_to :otrunk_report_template
  has_and_belongs_to_many :report_types
  
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

end
