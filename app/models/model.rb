class Model < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}models"
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
  
  acts_as_versioned :table_name => "#{RAILS_DATABASE_PREFIX}models_versions"
  
  has_many :activities
  belongs_to :user
  belongs_to :model_type
  
  has_many :subjects, :as => :subjectable
  has_many :levels, :as => :levelable

  has_many :learners, :as => :runnable
  
  # ancestry relationships
  belongs_to :parent, :class_name => "Model", :foreign_key => :parent_id
  has_many :children, :class_name => "Model", :foreign_key => :parent_id

  validates_uniqueness_of :name

  before_create :fix_nobundles

  before_save :check_sds_offering
  before_save :generate_short_name
  before_save :fix_nobundles

  def fix_nobundles
    unless self.nobundles
      self.nobundles = nil
    end
  end

end
