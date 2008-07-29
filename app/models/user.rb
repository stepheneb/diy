require 'digest/sha1'
require 'md5' 
class User < ActiveRecord::Base
  set_table_name "#{RAILS_DATABASE_PREFIX}users"
  include Changeable
  
  acts_as_replicatable
  
  self.extend SearchableModel

  @@searchable_attributes = %w{login email first_name last_name}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  # acts_as_reportable :only => [:names]

  belongs_to :vendor_interface
  has_many :activities, :order => 'name'
  has_many :external_otrunk_activities
  has_many :reports
  has_many :otrunk_report_templates
  has_many :models
  has_many :model_types
  has_many :data_filters
  has_many :calibrations
  has_many :physical_units
  has_many :probes
  has_many :probe_types
  has_many :vendor_interfaces
  
  has_many :memberships
  has_and_belongs_to_many :roles, :order => 'position', :join_table => "#{RAILS_DATABASE_PREFIX}roles_users", :foreign_key => "user_id"
  
  has_many :learners
#  has_many :runnables
#  has_many :groups, :through => :memberships
#  has_many :roles, :through => :memberships

# Virtual attribute for the unencrypted password
  attr_accessor :password

  before_validation :strip_spaces
  
  # strip leading and trailing spaces from names, login and email
  def strip_spaces  
    # these are conditionalized because it is called before the validation
    # so the validation will make sure they are setup correctly
    if self.first_name? then self.first_name.strip! end  
    if self.last_name? then self.last_name.strip! end  
    if self.login? then self.login.strip! end  
    if self.email? then self.email.strip! end  
  end

  validates_presence_of     :login, :email
  
  validates_each :first_name, :last_name, :login, :email do |model, attr, value| 
    unless value =~ /\S+/ 
      model.errors.add(attr, "must not be empty") 
    end 
  end
  
#  validates_presence_of     :password,                   :if => Proc.new { |u| !u.password.blank? && !u.password_confirmation.blank?}
#  validates_presence_of     :password_confirmation,      :if => Proc.new { |u| !u.password.blank? && !u.password_confirmation.blank?}
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false

  validate :valid_vendor_interface? 

  def valid_vendor_interface? 
    unless VendorInterface.exists?(vendor_interface_id)
      errors.add("VendorInterface", "is missing or invalid") 
    end 
  end
  
  def before_destroy
    
  end
  
  ARCHIVE_USER_ID = 2

  module TransferResourcesBelongingTo
    def transfer(transfer_to_user_id = ARCHIVE_USER_ID)
      self.each do |res|
        if res.class == Learner && l = Learner.find(:user_id => transfer_to_user_id, :runnable_id => res.runnable_id, :runnable_type => res.runnable_type)
          res.learner_sessions.transfer(l.id)
        else
          res.update_attributes!(:previous_user_id => res.user_id, :user_id => transfer_to_user_id)
        end
      end
    end
  end

  reflect_on_all_associations(:has_many).each {|assoc| assoc.send(:extend, TransferResourcesBelongingTo)}

  
  def any_has_manys?
    manys = self.class.reflect_on_all_associations(:has_many).collect do |assoc|
      [assoc.name, self.send(assoc.name).length]
    end.delete_if {|assoc| assoc[1] == 0}
    if manys.length == 0
      false
    else
      manys.collect {|i| "#{i[0]}: #{i[1]}"}.join(', ')
    end
  end
  
  def transfer_related_resources_to_user(transfer_to_user_id = ARCHIVE_USER_ID)
    self.class.reflect_on_all_associations(:has_many).find_all do |a| 
      self.send(a.name).length > 0
    end.each do |a| 
      self.send(a.name).transfer(transfer_to_user_id)
    end
  end

  before_save :encrypt_password
  before_save :check_sds_attributes

  def check_sds_attributes
    if self.sds_sail_user_id.blank?
        self.sds_sail_user_id = SdsConnect::Connect.create_sail_user(self.first_name, self.last_name)
    end
  end

  def name
    "#{first_name} #{last_name}"
  end
  
  # Returns True if User has one of the roles.
  # False otherwize.
  #
  # You can pass in a sequence of strings:
  #
  #  user.has_role("admin", "manager")
  #
  # or an array of strings:
  #
  #  user.has_role(%w{admin manager})
  #
  def has_role(*role_list)
    (roles.map{ |r| r.title.downcase } & role_list.flatten).length > 0
  end

  def does_not_have_role(*role_list)
    !has_role(role_list)
  end

  def make_user_a_member
    roles << Role.find_by_title('member')
  end
  
  # is this user the anonymous user?
  def anonymous?
    id == 1
  end
  
  # class method for returning the anonymous user
  def self.anonymous
    User.find(1)
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(identifier, password)
    user = User.remote_authenticate(identifier, password)
    user || local_authenticate(identifier, password)
  end
  
  def self.remote_authenticate(identifier, password)
    begin
      if ccuser = SunflowerMystriUser.find_user(identifier)
        if remote_authenticated?(password, ccuser.user_password)
          synch_with_local_user(ccuser, password)
        else
          nil
        end
      else
        nil
      end
    rescue StandardError
      nil
    end
  end

  def self.synch_with_local_user(ccuser, password)
    localuser = User.find_by_email(ccuser.user_email) 
    localuser = User.find_by_login(ccuser.user_username) unless localuser
    if localuser.blank?
      localuser = User.new
      localuser.login = ccuser.user_username
      localuser.email = ccuser.user_email || ccuser.user_username
      localuser.first_name = ccuser.user_first_name || ccuser.user_email[/(.*)@.*/, 1]
      localuser.last_name = ccuser.user_last_name || [/(.*)@(.*)/, 2]
      localuser.password = password
      localuser.password_confirmation = password
      localuser.vendor_interface_id = VendorInterface.find_by_short_name('vernier_goio').id
      localuser.roles << Role.find_by_title('member')
      localuser.save
    else
      if localuser.password_hash != ccuser.user_password
        localuser.password = password
        localuser.password_confirmation = password
        localuser.save
      end
    end
    localuser
  end
  
  def self.remote_authenticated?(password, remote_password)
    remote_encrypt(password) == remote_password
  end
  
  def self.local_authenticate(identifier, password)
    if u = User.find_by_login(identifier) || User.find_by_email(identifier)
      u.local_authenticated?(password) ? u : nil
    else
      nil
    end
  end
  
  def local_authenticated?(password)
    if crypted_password
      crypted_password == salted_sha_encrypt(password)
    else
      if password_hash == md5_encrypt(password)
        crypted_password = salted_sha_encrypt(password)
        true
      end
    end
  end
  
  # Encrypts some data with the salt.
  def self.local_encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def salted_sha_encrypt(password)
    self.class.local_encrypt(password, salt)
  end
  
  # Encrypts just using MD5 hash
  def md5_encrypt(password)
    self.class.remote_encrypt(password)
  end

    # Encrypts just using MD5 hash
  def self.remote_encrypt(password)
    MD5.hexdigest(password)
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = User.local_encrypt(password, salt)
      self.password_hash = MD5.hexdigest(password)
    end
    
    def password_required?
      (crypted_password.blank? && password_hash.blank?) || !(password.blank? && password_confirmation.blank?)
    end
end
