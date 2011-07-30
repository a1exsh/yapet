module SslAcception
  def self.included(target)
    target.extend(ClassMethods)
    target.alias_method_chain(:ssl_required?, :acception)
    target.prepend_before_filter(:require_ssl_acception)
    target.helper_method(:ssl_accepted?)
  end

  module ClassMethods
  end

  protected

  def ssl_required_with_acception?
    ssl_required_without_acception? if ssl_accepted?
  end

  def require_ssl_acception
    unless ssl_accepted?
      if ssl_required_without_acception?
        save_original_uri
        redirect_to about_ssl_path
      end
    else
      # make sure it never expires
      set_ssl_accepted
    end
  end

  def ssl_accepted?
    cookies[:ssl_accepted]
  end

  def set_ssl_accepted
    set_permanent_cookie :ssl_accepted, "yes"
  end

  private

  def set_permanent_cookie(key, value)
    cookies[key] = {
      :value => value,
      :expires => 10.years.from_now
    }
  end
end
