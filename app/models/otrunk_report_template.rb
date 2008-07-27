require 'open-uri'
require 'net/http'
require 'uri'

class OtrunkReportTemplate < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}otrunk_report_templates"
  include OtrunkSystem
  include Changeable
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  acts_as_versioned :table_name => "#{RAILS_DATABASE_PREFIX}otrunk_report_templates_versions" 

  has_many :reports
  belongs_to :user
  
  validates_presence_of :name
  validates_uniqueness_of :name

  before_create :generate_uuid

  before_save :generate_short_name
  before_save :check_for_external_otml

end
