require 'open-uri'
require 'net/http'
require 'uri'

class OtrunkReportTemplate < ActiveRecord::Base
  set_table_name "otrunk_report_templates"
  include Changeable
  
  acts_as_replicatable
  
  include OtrunkSystem
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  acts_as_versioned :table_name => "otrunk_report_templates_versions" 

  has_many :reports
  belongs_to :user
  
  validates_presence_of :name
  validates_uniqueness_of :name

  before_save :generate_short_name
  before_save :check_for_external_otml

end
