require 'hpricot'
require 'open-uri'
require 'net/http'
require 'uri'

class ExternalOtrunkActivity < ActiveRecord::Base
  set_table_name "external_otrunk_activities"
  include Changeable
  acts_as_replicatable
    
  include OtrunkSystem
  include SdsRunnable
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  acts_as_versioned :table_name => "external_otrunk_activities_versions"

  belongs_to :user

  has_many :levels, :as => :levelable
  has_many :subjects, :as => :subjectable

  has_many :subjects, :as => :subjectable
  has_many :levels, :as => :levelable

  has_many :learners, :as => :runnable
  has_many :reports, :as => :reportable
  
  # ancestry relationships
  belongs_to :parent, :class_name => "ExternalOtrunkActivity", :foreign_key => :parent_id
  has_many :children, :class_name => "ExternalOtrunkActivity", :foreign_key => :parent_id
  
  validates_uniqueness_of :name
  
  before_create :fix_nobundles

  before_save :check_sds_offering
  before_save :generate_short_name
  before_save :check_for_external_otml
  before_save :fix_nobundles
 
  def fix_nobundles
    unless self.nobundles
      self.nobundles = nil
    end
  end

end
