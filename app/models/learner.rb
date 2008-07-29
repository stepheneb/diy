class Learner < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}learners"
  
  acts_as_replicatable
  
  belongs_to :user
  belongs_to :runnable, :polymorphic => true  

  ARCHIVE_USER_ID = 2

  module TransferResourcesBelongingTo
    def transfer(transfer_to_user_id = ARCHIVE_USER_ID)
      self.each do |res| 
        res.update_attributes!(:user_id => transfer_to_user_id)
      end
    end
  end

  has_many :learner_sessions, :extend => TransferResourcesBelongingTo

  before_save :check_sds_workgroup
  
  def most_recent_not_empty_bundle_content_id
    wg = SdsConnect::Connect.workgroup(self.sds_workgroup_id)
    bundles = wg['workgroup']['bundles'].sort {|a, b| b['sail_session_start_time'] <=> a['sail_session_start_time'] }
    if bundles.length > 0
      bundles.first['bundle_content_id']
    else
      nil
    end
  end
  
  def ot_learner_data
    SdsConnect::Connect.workgroup_ot_learner_data(self.sds_workgroup_id)
  end
  
  def create_session
    self.learner_sessions << LearnerSession.new
  end
  
  def check_sds_workgroup
    if self.sds_workgroup_id.blank?
      self.sds_workgroup_id = SdsConnect::Connect.create_workgroup(self.user.name, self.runnable.sds_offering_id)
      SdsConnect::Connect.create_workgroup_membership(self.sds_workgroup_id, self.user.sds_sail_user_id)
    end
  end
end
