class MailNotifier < ActionMailer::Base
  layout 'mail_notification'

  DO_NOT_REPLY_ADDRESS = "Do not Reply <no-reply@yapet.net>"

  def created_new_user_notification(email, password)
    @email = email
    @password = password

    recipients @email
    from       DO_NOT_REPLY_ADDRESS
    subject    _("Your brand new 'YaPET: a Personal Expense Tracker' account")
  end

  def added_user_notification(email, password, owner_email)
    @email = email
    @password = password
    @owner_email = owner_email

    recipients @email
    from       DO_NOT_REPLY_ADDRESS
    subject    _("YaPET: a Personal Expense Tracker -- invitation")
  end

  def password_reset_request(email, pwrequest)
    @email = email
    @request_url = confirm_password_reset_request_url(:id => pwrequest.code)

    recipients @email
    from       DO_NOT_REPLY_ADDRESS
    subject    _("Password reset request for your YaPET account")
  end

  def invitation_notification(invite, comment)
    @invite = invite
    @comment = comment
    @invitation_url = invitation_url(:id => invite.code)

    recipients @invite.email
    from       DO_NOT_REPLY_ADDRESS
    subject    _("Invitation to YaPET")
  end
end
