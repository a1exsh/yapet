class SettingsController < Settings::ControllerBase
  def show
    redirect_to edit_settings_path
  end

  def new
    redirect_to edit_settings_path
  end
  
  # GET /settings
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  def create
    redirect_to edit_settings_path
  end

  # PUT /settings
  def update
    if @current_user.update_attributes(params[:user])
      I18n.locale = @current_user.locale
      flash[:notice] = _("Settings saved")
    else
      flash[:error] = _("Not saved!")
    end
    respond_to do |format|
      format.html { redirect_to edit_settings_path }
#      format.js   { render :status => :ok, :text => "" }
    end
  end

  def toggle_show_guide
    @current_user.update_attribute(:show_guide, !@current_user.show_guide)
    head :ok
  end
end
