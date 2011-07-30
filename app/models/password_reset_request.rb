class PasswordResetRequest < ActiveRecord::Base
  belongs_to :user

  named_scope :expired, lambda {
    { :conditions => ["created_at < ?", 1.day.ago] }
  }

  include SecretCodes

  def initialize(*args)
    super(*args)
    self.code = make_secret_code
  end
end
