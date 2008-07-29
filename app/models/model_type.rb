class ModelType < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}model_types"
  include Changeable
  
  acts_as_replicatable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  

  has_many :models
  belongs_to :user
end
