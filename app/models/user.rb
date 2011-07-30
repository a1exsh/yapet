require 'digest/sha1'
require 'base64'

class User < ActiveRecord::Base
  belongs_to :account

  has_many :other_users, :through => :account, :source => :users,
    :class_name => 'User', :conditions => 'users.id != #{id}'

  has_many :password_reset_requests

  attr_accessible :email, :password
  attr_accessible :timezone, :records_per_page, :locale, :show_guide

  include CustomValidations

  class CannotInvite < Exception
  end

  validates_email_address :email
  validates_uniqueness_of :email

  validates_numericality_of :invites_left,
    :greater_than_or_equal_to => 0,
    :less_than => 100

  DEFAULT_TIMEZONE = 'Kyev'

  def initialize(*args)
    super(*args)
    self.timezone ||= DEFAULT_TIMEZONE
  end
  
  def self.authenticate(email, secret)
    user = find_by_email(email)
    if user && hash_password(secret, user.salt) == user.hashed_password
      user
    end
  end

  def remember_code
    Digest::SHA1.hexdigest(email + "#" + created_at.to_s)
  end

  def to_xml(options = {})
    options[:only] = [:id, :account_id]
    super(options)
  end

  def password=(secret)
    @password = secret
    self.salt = self.object_id.to_s + rand.to_s
    self.hashed_password = User.hash_password(secret, self.salt)
  end

  def password
    @password
  end

  def is_admin?
    self.id == 0
  end

  def exclusive_account?
    account.users.count == 1
  end

  def account_owner?
    account.owner_id == self.id
  end

  def can_invite?
    created_at < 1.month.ago
  end

  def no_invites_left?
    # desipte the validations it still might be less than zero: after
    # a failed validation
    invites_left <= 0
  end

  def self.random_password
    random_base64_string[0,8]
  end

  def self.random_sandbox_email
    random_base64_string[0,10] + "@sandbox.yapet.net"
  end

  def self.new_for_sandbox(attributes = {})
    User.new(attributes.merge(:email => random_sandbox_email, :password => ""))
  end

  def create_with_new_account!(*args, &block)
    transaction do
      self.account = Account.create!(*args, &block)
      save!

      # TODO: does it have to be so ugly?
      #
      # we don't have an id until we save successfully to database
      account.owner_id = self.id

      # changes to self.account will be lost unless we save them
      account.save!
    end
  end

  def on_friend_invitation
    raise CannotInvite unless can_invite?

    # update_attributes won't work, because invites_left isn't accessible
    self.invites_left -= 1
    save!
  end

  private

  def self.hash_password(secret, salt)
    Digest::SHA1.hexdigest(secret + "#" + salt)
  end

  # returns a random string of length 13 like "3SWua2qA5z8=\n", the
  # last three chars are always the same
  def self.random_base64_string
    Base64.encode64([rand].pack("d"))
  end
end
