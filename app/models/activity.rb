class Activity < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}activities"
  include Changeable
  
  acts_as_replicatable
  
  include OtrunkSystem
  include SdsRunnable
  acts_as_versioned :table_name => "#{RAILS_DATABASE_PREFIX}activities_versions"
  include HasImage

  self.extend SearchableModel
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    
  end

  belongs_to :user
  belongs_to :probe_type
  belongs_to :model

  belongs_to :second_probe_type, :class_name => "ProbeType", :foreign_key => :collectdata2_probetype_id
  belongs_to :second_model, :class_name => "Model", :foreign_key => :collectdata2_model_id
  belongs_to :third_probe_type, :class_name => "ProbeType", :foreign_key => :collectdata3_probetype_id
  belongs_to :third_model, :class_name => "Model", :foreign_key => :collectdata3_model_id
  belongs_to :fourth_probe_type, :class_name => "ProbeType", :foreign_key => :further_probetype_id
  belongs_to :fourth_model, :class_name => "Model", :foreign_key => :further_model_id
  
  # ancestry relationships
  belongs_to :parent, :class_name => "Activity", :foreign_key => :parent_id
  has_many :children, :class_name => "Activity", :foreign_key => :parent_id

# has_many :tagged_posts, :through => :taggings, :source => :taggable, :source_type => 'Post' 
#  has_many :subjects, :through => :subjectings, :source => :subjectable, :source_type => 'Activity'

  has_many :unit_activities 
  has_many :units, :through => :unit_activities 

  has_many :subjectings, :as => :subjectable
  has_many :subjects, :through => :subjectings
  
  has_many :levels, :as => :levelable

  has_many :learners, :as => :runnable 

  validates_presence_of :name, :introduction
  validates_uniqueness_of :name

  before_create :generate_digest
  before_create :fix_nobundles

  before_save :check_sds_offering
  before_save :generate_short_name
  before_save :generate_digest
  before_save :fix_nobundles

  def self.new(options=nil)
    a = super(options)
    temperature = ProbeType.find_by_name("Temperature") 
    a.probe_type = temperature unless a.probe_type
    a.second_probe_type = temperature unless a.second_probe_type
    a.third_probe_type = temperature unless a.third_probe_type
    a.fourth_probe_type = temperature unless a.fourth_probe_type
    a
  end

  def generate_digest
    digest = calculate_content_digest
    if digest != self.content_digest
      self.content_digest = digest
    end
  end
  
  def fix_nobundles
    unless self.nobundles
      self.nobundles = nil
    end
  end

  def calculate_content_digest
    content = %w{introduction standards probe_type_id materials safety proced predict collectdata analysis conclusion further}.collect {|v| self.send(v)}.join
    Base64.encode64(Digest::MD5.digest(content)).strip
  end
  
  # This method allows an easy production of an array of strings
  # representing all the different and unique interactive components
  # used in an activity or a collection of activities. 
  # For example: 
  # activities = Activity.find(:all)
  # [:models, :probes].collect {|k| activities.collect {|a| a.interactive_components[k] } }.flatten.uniq
  # => ["Molecular Workbench", "PhET Circuit Construction Kit", "NetLogo", "PhET Wave Interference Model", 
  #     "Temperature", "Light", "Force (5N)", "Motion", "Voltage", "Relative Humidity", "Raw Voltage"]
  def interactive_components
    p, m = [], []
    # collect probe_type names
    begin
      if collectdata_probe_active then p << probe_type.name end
      if collectdata2_probe_active then p << second_probe_type.name end
      if collectdata3_probe_active then p << third_probe_type.name end
      # collect model_type names
      if collectdata_model_active && model then m << model.model_type.name end
      if collectdata2_model_active && second_model then m << second_model.model_type.name end
      if collectdata3_model_active && third_model then m << third_model.model_type.name end
      if (further_model_active && fourth_model) then m << fourth_model.model_type.name end
    rescue NoMethodError => e
      logger.warn("Exception: #{e}\n\n#{e.backtrace.join("\n")}")
    end
    {:probes => p.uniq, :models => m.uniq }
  end

  def contains_active_model(model_object)
    m = []
    if collectdata_model_active && model == model_object then m << model end
    if collectdata2_model_active && second_model == model_object then m << second_model end
    if (collectdata3_model_active && third_model) then m << third_model.model_type.name end
    if (further_model_active && fourth_model) then m << fourth_model.model_type.name end
    m.length > 0
  end
  
  class MyOtmlHelper
    include ApplicationHelper
    include OtmlHelper
    include ERB::Util
    attr_accessor :xml

    def initialize(activity)
      @probetypes = ProbeType.find(:all)
      @vendor_interface = VendorInterface.find(:first)
      @savedata = false
      @nobundles = true
      # for now maybe this will work
      @includes = []
      @overlays = []
      @bundles = []
      @activity = activity
      @xml = Builder::XmlMarkup.new
    end

    def get_binding
      binding
    end
    def process_local_image_urls(html)
      html
    end
    def process_local_url(url)
      url 
    end
    def link_to(a,b,c)
      ""
    end
  end 
  
  def otml
    helper = MyOtmlHelper.new(self)
    view_file = "#{RAILS_ROOT}/app/views/activities/otml.rxml"
    # requires open-uri
    template = open(view_file).read
    eval template,helper.get_binding
    return helper.xml.clone
  end
end
