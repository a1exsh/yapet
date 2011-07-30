# -*- coding: utf-8 -*-
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'ruby-debug'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => '659cd30c12e9fbdaf171db3b4d5d99d1'
  protect_from_forgery :only => [:create, :update, :destroy]
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :email

  protected

  include ExceptionNotifiable
  include LocaleHandling
  include LoginManagement

  # this has to go before SslRequirement, as server certificate
  # contains www in Common Name
  before_filter :ensure_www_subdomain if Rails.env.production?

  include SslRequirement
  include SslAcception

  # for quick stats
  include Stats

  # this has to go before authenticate or I18n.locale will be reset to :en
  before_filter :set_gettext_locale

  before_filter :setup_user_time_zone
  before_filter :setup_locale

  after_filter :discard_flash_on_ajax

  layout :select_layout

  rescue_from ActiveRecord::RecordInvalid do |exception|
    #logger.info "!!! rescue_from RecordInvalid: #{exception}"

    errors = exception.record.errors
    respond_to do |format|
      format.html { head :unprocessable_entity }
      format.js   { render :text => errors.full_messages.join("\n"),
        :status => :unprocessable_entity }
      format.xml  { render :xml => errors, :status => :unprocessable_entity }
    end
  end

  rescue_from ActionController::RedirectBackError do
    redirect_to root_path
  end

  def rescue_action(exception)
    #logger.info "!!! rescue_action: #{exception}"

    handled = super(exception)
    if !handled && request.xhr?
      log_error(exception)

      render :text => _("Internal Server Error"),
        :status => :internal_server_error

      # TODO: will exception notification be sent?
      # ExceptionNotifier.deliver_exception_notification(exception, self, request, nil)
    end
  end

  def rescue_action_without_handler(exception)
    super(exception) unless request.xhr?
  end
  
  def ensure_www_subdomain
    if request.domain && request.subdomains != ["www"]
      flash.keep
      redirect_to request.protocol + "www." + request.domain + "/"
    end
  end

  # turn off SSL in dev and tests
  unless Rails.env.production?
    def ssl_required?
      false
    end

    def ssl_allowed?
      false
    end
  end

  LOCALES_WITH_NAMES = [["Русский", "ru"], ["English", "en"]]

  def set_gettext_locale
    # put back Russian i18n backend likely overridden by gettext
    if I18n.backend.is_a? GettextI18nRails::Backend
      I18n.backend.backend = Russian::i18n_backend_class.new
    end

    FastGettext.text_domain = 'app'
    FastGettext.available_locales = LOCALES_WITH_NAMES.map(&:last)
    super

    I18n.locale = :ru
    @locales_with_names = LOCALES_WITH_NAMES
  end

  def setup_user_time_zone
    Time.zone = @current_user.timezone if logged_in?
  end

  def setup_locale
    if logged_in?
      I18n.locale = @current_user.locale
    elsif cookies[:locale]
      I18n.locale = cookies[:locale]
    end
  end

  def discard_flash_on_ajax
    flash.discard if request.xhr?
  end

  def select_layout
    @use_undecorated_layout ||= false
    'application' unless request.xhr?
  end

  def use_undecorated_layout
    @use_undecorated_layout = true
  end
end
