module SessionsHelper
  def logout_url
    if Rails.env.production?
      session_url(:protocol => "https")
    else
      session_path
    end
  end
end
