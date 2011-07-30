module LoginManagement
  def self.included(target)
    target.extend(ClassMethods)
    target.before_filter(:authenticate)
    target.helper_method(:current_user, :current_account,
                         :logged_in?, :logged_in_as_admin?)
  end

  module ClassMethods
    def login_required(options = {})
      before_filter :require_login, options
    end

    def admin_required(options = {})
      before_filter :require_admin, options
    end
  end

  protected

  def authenticate
    #logger.info "authenticate"
    if session[:user_id]
      #logger.info "logging in with session[:user_id]"
      @current_user = User.find(session[:user_id])
    elsif cookies[:remembered_id]
      #logger.info "logging in with cookies[:remembered_id]"
      user = User.find(cookies[:remembered_id])
      if user.remember_code == cookies[:remembered_code]
        login(user, true)
      else
        logger.error "rejected cookies[:remembered_code]"
      end
    end
  rescue ActiveRecord::RecordNotFound
    # nothing to do
    #logger.error "authenticate: RecordNotFound"
  end

  def login(user, remember = false)
    @current_user = user
    session[:user_id] = user.id

    remember_current_user if remember
  end

  def remember_current_user
    expire_date = 1.month.from_now

    cookies[:remembered_id] = {
      :value => @current_user.id.to_s,
      :expires => expire_date
    }
    cookies[:remembered_code] = {
      :value => @current_user.remember_code,
      :expires => expire_date
    }
  end

  def logout
    reset_session
    cookies.delete :remembered_id
    cookies.delete :remembered_code
    @current_user = nil
  end

  def current_user
    @current_user
  end

  def current_account
    @current_user.account
  end

  def logged_in?
    !@current_user.nil?
  end

  def logged_in_as_admin?
    logged_in? && @current_user.is_admin?
  end

  def require_login
    unless logged_in?
      save_original_uri
      redirect_to new_session_path
    end
  end

  def require_admin
    unless logged_in_as_admin?
      save_original_uri
      redirect_to new_session_path
    end
  end

  def save_original_uri
    session[:original_uri] ||= request.request_uri
    #logger.info "save_original_uri: " + session[:original_uri]
  end

  def redirect_to_original_uri
    #logger.info "redirect_to_original_uri: " + session[:original_uri]
    redirect_to(session[:original_uri] || dashboard_path)
    session[:original_uri] = nil
  end
end
