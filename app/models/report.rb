class Report < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}reports"
  include Changeable
  
  acts_as_replicatable
  
  self.extend SearchableModel

  belongs_to :user
  belongs_to :reportable, :polymorphic => true  
  belongs_to :otrunk_report_template
  
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

end
