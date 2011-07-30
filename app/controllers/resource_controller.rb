class ResourceController < ApplicationController
  include Searching

  login_required
  force_ssl

  before_filter :find_records_for_index_on_current_account,
    :only => :index

  before_filter :find_record_on_current_account,
    :only => [:show, :edit, :update, :destroy]

  before_filter :create_record_on_current_account,
    :only => [:new, :create]

  def index
    expires_now

    respond_to do |format|
      format.html
      format.xml  { render :xml => records }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => record }
    end
  end

  def new
    respond_to do |format|
      format.html
      format.xml  { render :xml => record }
    end
  end

  def edit
  end

  def create
    create_or_update
  end

  def update
    create_or_update
  end

  def destroy
    record.destroy

    respond_to do |format|
      format.html { redirect_to index_path }
      format.js   { head :ok }
      format.xml  { head :ok }
    end
  end

  protected

  def model_name
    @model_name ||= self.controller_name.singularize
  end

  def model_class
    @model_class ||= model_name.camelize.constantize
  end

  def index_path
    self.send(:"#{controller_name}_path")
  end

  def records
    self.instance_variable_get(:"@#{controller_name}")
  end

  def records=(objs)
    self.instance_variable_set(:"@#{controller_name}", objs)
  end

  def record
    self.instance_variable_get(:"@#{model_name}")
  end

  def record=(obj)
    self.instance_variable_set(:"@#{model_name}", obj)
  end

  def scope_for_records_on_current_account
    current_account.send(self.controller_name.to_sym)
  end

  def find_records_for_index_on_current_account(options = {})
    scope = scope_for_records_on_current_account
    opts = { :page => params[:page],
      :per_page => @current_user.records_per_page }.merge(options)
    coll = scope.paginate(opts)

    if coll.out_of_bounds? && coll.total_pages > 0
      opts[:page] = coll.total_pages
      coll = scope.paginate(opts)
    end
    
    self.instance_variable_set(:"@#{controller_name}", coll)
  end

  def find_record_on_current_account
    scope = scope_for_records_on_current_account
    self.instance_variable_set(:"@#{model_name}", scope.find(params[:id]))
  rescue ActiveRecord::RecordNotFound
    flash[:error] = _("The requested record was not found.  It may have been removed or you have mistyped the URL.")
    redirect_to index_path
  end

  def create_record_on_current_account
    scope = scope_for_records_on_current_account
    self.instance_variable_set(:"@#{model_name}", scope.new)
  end

  def create_or_update
    respond_to do |format|
      begin
        record.transaction{ record.update_attributes!(params[model_name.to_sym]) }
        format.html { redirect_to record }
        format.js   { head :ok }
        format.xml  { render :xml => record, :status => :created,
          :location => record }
      rescue ActiveRecord::RecordInvalid
        format.html { render :action => "new" }
        format.js   { render :text => record.errors.full_messages.join("\n"),
          :status => :unprocessable_entity }
        format.xml  { render :xml => record.errors,
          :status => :unprocessable_entity }
      end
    end
  end
end
