class Settings::PasswordsController < Settings::ControllerBase
  def show
    redirect_to edit_settings_password_path
  end

  def new
    redirect_to edit_settings_password_path
  end

  # GET /settings/password/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  def create
    redirect_to edit_settings_password_path
  end

  # PUT /settings/password
  def update
    success = false

    if User.authenticate(@current_user.email, params[:old_password]).nil?
      flash[:error] = _("Mistyped current password")
    elsif params[:new_password] != params[:confirm_password]
      flash[:error] = _("Password confirmation does not match new password")
    else
      @current_user.password = params[:new_password]
      if !@current_user.save
        flash[:error] = _("Internal Server Error")
      else
        flash[:notice] = _("Password changed")
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
    redirect_to edit_settings_password_path
  end
end
