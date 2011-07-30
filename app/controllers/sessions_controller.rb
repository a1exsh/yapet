class SessionsController < ApplicationController
  force_ssl

  def new
    logout if logged_in?

    @email = ""

    # prevent caching of login form
    expires_now
  end

  def create
    @email = params[:email]
    @password = params[:password]

    user = User.authenticate(@email, @password)
    if user
      login(user, params[:remember])
      redirect_to_original_uri
    else
      flash[:error] = _("Login invalid")
      render :action => :new
    end
  end

  def destroy
    logout
    redirect_to new_session_path
  end
end
