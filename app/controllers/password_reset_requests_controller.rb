class PasswordResetRequestsController < ApplicationController
  ssl_required :confirm, :fulfill

  def index
    redirect_to new_password_reset_request_path
  end

  def show
  end

  def new
    @email = ""
  end

  def create
    flash.discard

    @email = params[:email]
    if @email.blank?
      flash[:error] = _("Please specify a valid email address")
      render :action => "new"
    else
      user = User.find_by_email(@email)
      if user.nil?
        flash[:error] = _("The specified email address is not registered")
        render :action => "new"
      else
        I18n.locale = user.locale

        @request = user.password_reset_requests.create!
        MailNotifier.deliver_password_reset_request(@email, @request)

        flash[:notice] = _("Email with instructions sent to %s.  If you didn't receive the message, please check your Spam folder or try again.") % @email

        render :action => "show"
      end
    end
  end

  def confirm
    @email = ""
    @request = PasswordResetRequest.find_by_code(params[:id])
    if @request.nil?
      flash[:error] = _("This password reset request is invalid (it might have expired).  Please fill the new request below. ")
      redirect_to new_password_reset_request_path
    else
      # prepare render 'confirm' template with user's locale
      I18n.locale = @request.user.locale
    end
  end

  def fulfill
    flash.discard

    @email = ""
    @request = PasswordResetRequest.find_by_code(params[:id])
    if @request.nil?
      redirect_to new_password_reset_request_path
    else
      user = @request.user
      I18n.locale = user.locale

      if params[:new_password] != params[:confirm_password]
        flash[:error] = _("Password confirmation does not match new password")
        render :action => "confirm"
      else
        user.password = params[:new_password]
        if !user.save
          flash[:error] = _("Internal Server Error")
          render :action => "confirm"
        else
          flash[:notice] = _("Password changed")
          session[:user_id] = user.id
          @request.destroy
          redirect_to root_path
        end
      end
    end
  end
end
