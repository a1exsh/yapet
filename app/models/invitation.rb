class Invitation < ActiveRecord::Base
  include SecretCodes
  include CustomValidations

  named_scope :expired, lambda {
    { :conditions => ["created_at < ?", 1.week.ago] }
  }

  attr_accessible :email, :locale, :inviting_user_email

  validates_email_address :email
  validates_uniqueness_of :email

  def initialize(*args)
    super(*args)
    self.code = make_secret_code(email, locale, inviting_user_email)
  end
end
