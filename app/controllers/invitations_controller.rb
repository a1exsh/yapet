class InvitationsController < ApplicationController
  before_filter :find_invitation, :only => [:show, :accept]
  before_filter :use_undecorated_layout, :only => [:new, :create]

  login_required :only => [:new, :create]
  before_filter :check_can_invite, :only => [:new, :create]
  before_filter :parse_invite_params, :only => [:new, :create]

  force_ssl

  def new
    make_invite_preview

    respond_to do |format|
      format.html
      format.js { render :text => @preview }
    end
  end

  def create
    status = :unprocessable_entity

    if User.find_by_email(@invite.email)
      @invite_failure = _("This user is already invited.")
    else
      @invite.save!
      current_user.on_friend_invitation

      with_locale @invite.locale do
        MailNotifier.deliver_invitation_notification(@invite, @comment)
      end

      @invite_success = _("Invitation sent.")
      @invite = Invitation.new(:locale => @invite.locale)
      status = :ok
    end
  rescue ActiveRecord::RecordInvalid
    if current_user.no_invites_left?
      @invite_failure = _("Sorry, no invitations left.")
      @invite.email = ""
    else
      @invite_failure = _("Invalid email or this user is already invited.")
    end
  ensure
    respond_to do |format|
      format.js { render :partial => "quick", :status => status }
      format.html do
        make_invite_preview
        render :action => "new", :status => status
      end
    end
  end

  def show
    redirect_to root_path if logged_in?

    @email = @invite.email unless @invite.nil?
  end

  def accept
    if @invite.nil?
      render :action => "show"
      return
    end

    @email = params[:email]

    password = params[:password]
    if password != params[:confirm_password]
      flash[:error] = _("Password doesn't match confirmation")
      render :action => "show"
    else
      password = User.random_password if password.blank?

      user = User.new(:email => @email, :password => password,
                      :locale => I18n.locale)
      user.create_with_new_account!

      MailNotifier.deliver_created_new_user_notification(@email, password)

      @invite.destroy
      login(user)

      flash[:notice] = _("Congratulations, you've been successfully registered!")
      redirect_to root_path
    end
  rescue ActiveRecord::RecordInvalid
    flash[:error] = user.errors.full_messages.join("\n")
    render :action => "show"
  end

#  def destroy
#  end

  private

  def find_invitation
    @invite = Invitation.find_by_code(params[:id])

    if @invite.present? && cookies[:locale].blank?
      I18n.locale = cookies[:locale] = @invite.locale
    end
  end

  def check_can_invite
    redirect_to root_path unless current_user.can_invite?
  end

  def parse_invite_params
    invite_params = params[:invitation] || {}
    invite_params[:locale] ||= current_user.locale
    invite_params[:inviting_user_email] = current_user.email
    @invite = Invitation.new(invite_params)

    @comment = params[:comment]
  end

  def make_invite_preview
    @invite.code = "secret-invite-code"

    mail = with_locale @invite.locale do
      MailNotifier.create_invitation_notification(@invite, @comment)
    end

    @preview = mail.body
    @preview.tr!("\n", " ")
    @preview.gsub!(/.*<!--begin-preview-cut-->/, "")
    @preview.gsub!(/<!--end-preview-cut-->.*/, "")
    @preview.gsub!(@invite.code, "...")
  end
end
