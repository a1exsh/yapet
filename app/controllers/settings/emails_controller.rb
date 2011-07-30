class Settings::EmailsController < Settings::ControllerBase
  def show
    redirect_to edit_settings_email_path
  end

  def new
    redirect_to edit_settings_email_path
  end
  
  # GET /settings/email/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  def create
    redirect_to edit_settings_email_path
  end

  # PUT /settings/email
  def update
    success = false

    if User.authenticate(@current_user.email, params[:password]).nil?
      flash[:error] = _("Mistyped password")
    else
      old_email = @current_user.email
      @current_user.email = params[:new_email]
      if !@current_user.save
        flash[:error] = @current_user.errors.full_messages
        @current_user.email = old_email
      else
        flash[:notice] = _("Email address changed")
        success = true
      end
    end

    respond_to do |format|
      format.html do
        if success
          redirect_to edit_settings_path
        else
          render :action => "edit"
        end
      end
    end
  end

  def destroy
    redirect_to edit_settings_email_path
  end
end
