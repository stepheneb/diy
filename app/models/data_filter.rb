class DataFilter < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}data_filters"
  include Changeable
  acts_as_replicatable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  belongs_to :user
  has_many :calibrations

end
