class Model < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}models"
  include Changeable
  
  acts_as_replicatable
  
  include OtrunkSystem
  include SdsRunnable
  acts_as_versioned :table_name => "#{RAILS_DATABASE_PREFIX}models_versions"
  include HasImage
  
  self.extend SearchableModel
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  

  has_many :activities, 
    :conditions => {:collectdata_model_active => true  }
  has_many :activities_2, :class_name => "Activity", :foreign_key => :collectdata2_model_id, 
    :conditions => {:collectdata2_model_active => true }
  has_many :activities_3, :class_name => "Activity", :foreign_key => :collectdata3_model_id,
    :conditions => {:collectdata3_model_active => true }
  has_many :activities_4, :class_name => "Activity", :foreign_key => :further_model_id, 
    :conditions => {:further_model_active => true}
  
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

  def included_activities
    return (activities + activities_2 + activities_3 + activities_4).compact.uniq.sort { |a,b| a.name <=> b.name }
  end

  def activity_use_count
    included_activities.size
  end

end
