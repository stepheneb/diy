require 'open-uri'
require 'net/http'
require 'uri'

class OtrunkReportTemplate < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}otrunk_report_templates"
  include Changeable
  
  acts_as_replicatable
  
  include OtrunkSystem
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  
    def find_or_create_by_url(url,name="default")
      found = self.find_by_external_otml_url(url)
      unless found.nil?
        return found
      end
      options = {
        :public => true,
        :description => name,
        :short_name => name,
        :name => name,
        :user => User.find_by_login('cstaudt') || User.find(:first),
        :external_otml_url => url,
        :external_otml_always_update => true
      }
      return self.create(options)
    end

  end
  
  acts_as_versioned :table_name => "#{RAILS_DATABASE_PREFIX}otrunk_report_templates_versions" 

  has_many :reports
  belongs_to :user
  
  validates_presence_of :name
  validates_uniqueness_of :name

  before_save :generate_short_name
  before_save :check_for_external_otml

end
