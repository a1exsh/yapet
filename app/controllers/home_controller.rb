class HomeController < ApplicationController
  login_required :only => :dashboard
  ssl_required :dashboard

  def index
    if logged_in?
      flash.keep
      redirect_to dashboard_path
    end
  end

  def dashboard
  end

  def language
    cookies[:locale] = params[:id]
    redirect_to :back
  end

  def testing
  end
end
