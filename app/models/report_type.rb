class ReportType < ActiveRecord::Base
  set_table_name "report_types"
  include Changeable
  
  acts_as_replicatable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{uri name}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  validates_presence_of :uri
  validates_uniqueness_of :uri
  
  has_and_belongs_to_many :reports, :join_table => "report_types_reports"
  belongs_to :user
end
