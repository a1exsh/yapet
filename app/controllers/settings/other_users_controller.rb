class Settings::OtherUsersController < Settings::ControllerBase
  before_filter :deny_sandbox_accounts
  before_filter :require_account_owner, :except => :index

  # GET /settings/other_users
  def index
    @users = @current_user.other_users
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    redirect_to settings_other_users_path
  end

  # GET /settings/other_users/new
  def new
    @users = current_account.users
    @sent_emails = []
    @failed_emails = {}
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    redirect_to settings_other_users_path
  end

  # POST /settings/other_user
  def create
    emails = params[:emails].values.reject{ |email| email.blank? }
    @sent_emails = []
    @failed_emails = {}
    if share_account_with_new_users(emails)
      respond_to do |format|
        format.html { redirect_to settings_other_users_path }
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
      end
    end
  end

  def update
    redirect_to settings_other_users_path
  end

  # GET /settings/other_user/:id/remove
  def remove
    @user = @current_user.other_users.find(params[:id])
    respond_to do |format|
      format.html # remove.html.erb
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to settings_other_users_path }
    end
  end

  # DELETE /settings/other_user/:id
  def destroy
    other = @current_user.other_users.find(params[:id])
    other.destroy

    respond_to do |format|
      format.html { redirect_to settings_other_users_path }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to settings_other_users_path }
    end
  end

  private

  def deny_sandbox_accounts
    redirect_to edit_settings_path if current_account.is_sandbox?
  end

  def require_account_owner
    redirect_to settings_other_users_path unless @current_user.account_owner?
  end

  def share_account_with_new_users(emails)
    emails.each do |email|
      begin
        password = User.random_password
        user = current_account.users.create!(:email => email,
                                             :password => password)
        MailNotifier.deliver_added_user_notification(email, password,
                                                     @current_user.email)
        @sent_emails << email
      rescue ActiveRecord::RecordInvalid
        @failed_emails[email] = $!.record.errors.full_messages
      rescue
        log_error($!)
        @failed_emails[email] = _("Could not send an invitation to this address.  Please check that the address is correct or retry later")
      end
    end
    @failed_emails.empty?
  end
end
