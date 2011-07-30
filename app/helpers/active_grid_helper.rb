module ActiveGridHelper
  def grid(model, collection, options = {}, &block)
    GridBuilder.new(self, model, collection, options, block)
  end

  def grid_for(collection, options = {}, &block)
    GridBuilder.new(self, self.controller_name.singularize, collection,
                    options, block)
  end

  protected

  class GridColumn
    def initialize(template, title, html_options, options, block)
      @t = template
      @title = title
      @html_options = html_options
      @options = options
      @block = block
    end

    def render_head
      @t.content_tag :th, ERB::Util.h(@title), @html_options
    end

    def render_cell(record)
      @t.content_tag :td, @html_options do
        @block.call(record)
      end
    end

    def render_new_record_form_cell(form)
      @t.content_tag :td, @html_options do
        form.render_cell @options
      end
    end
  end

  class NewRecordForm
    attr_reader :reload_page_js

    def initialize(grid)
      @grid = grid
      @t = grid.template
      @model = grid.model
      @columns = grid.columns
      @reload_page_js = grid.reload_page_js \
        :params => { :_grid_form => 'new_record' },
        :complete => "$('#{form_row_id}').select('input').first().focus()"
    end

    def form_row_id
      @form_row_id ||= "#{@grid.grid_id}_new_#{@model}"
    end

    def submit_link_id
      @submit_link_id ||= "#{@model}_submit"
    end

    def render_row
      options = { :id => form_row_id, :class => 'grid_new_record' }
      options[:style] = 'display:none;' \
        unless @t.params[:_grid_form] == 'new_record'
      @t.content_tag :tr, options do
        new_record_form
      end
    end

    def new_record_form
      @t.instance_variable_set(:"@#{@model}", @model.camelize.constantize.new)

      #status_icon_td \
      #+
      @columns.map{|col| col.render_new_record_form_cell(self)}.join \
      + submit_link_td \
      + cancel_link_td
    end

    def render_cell(options)
      return "" if options[:no_input]

      if options[:input_replacement]
        options[:input_replacement]
      else
        link_id = submit_link_id
        submit_js = @t.update_page do |page|
          page[link_id].onclick
        end
        @t.content_tag :form, :onsubmit => submit_js + "return false;" do
          render_input(options) \
          + @t.tag(:input, :type => 'submit', :style => 'display:none;')
        end
      end
    end

    def render_input(options)
      if options[:input].blank?
        @t.tag :input, :type => 'text'
      else
        options[:input]
      end
    end

    def status_icon_td
      @t.content_tag :td do
        status_icon
      end
    end

    def status_icon
      @t.content_tag :div, '', :class => 'icon', :id => status_icon_id,
        :style => "display: none;"
    end

    def submit_link_td
      @t.content_tag :td do
        hidden_input + submit_link + status_icon
      end
    end

    # def authenticity_token_input
    #   @t.hidden_field_tag 'authenticity_token', @t.form_authenticity_token
    # end

    def hidden_input
      @t.hidden_field_tag '_grid_form', 'new_record'
    end

    def submit_link
      submit_params = "Form.serializeElements($('#{form_row_id}').select('input'))"
      show_status_icon_js = "$('#{submit_link_id}').hide();" \
        + "$('#{status_icon_id}').show();"
      hide_status_icon_js = "$('#{status_icon_id}').hide();" \
        + "$('#{submit_link_id}').show();"

      loading_js = show_status_icon_js + "startSpinner('#{status_icon_id}')"
      failure_js = "var errorText=request.responseText.substring(0,256);setStatusIcon('#{status_icon_id}','error',errorText);alert(errorText);" + hide_status_icon_js
      success_js = reload_page_js

      @t.link_to_remote '', {
        :url => @grid.submit_url,
        :with => submit_params,
        :loading => loading_js,
        :failure => failure_js,
        :success => success_js },
        { :class => 'icon icon-ok', :id => submit_link_id }
#      @t.link_to_function '!', "alert()"
    end

    def cancel_link_td
      @t.content_tag :td do
        clear_js = clear_status_icon_js

        grid_form_row_id = form_row_id
        inputs_selector = "##{form_row_id} input"
        grid_action_links_row_id = @grid.action_links_row_id

        update_function = @t.update_page do |page|
          page[grid_form_row_id].hide
          page.select(inputs_selector).each do |input|
            input.value = ''
          end
          page << clear_js
          page[grid_action_links_row_id].show
        end
        
        @t.link_to_function '', update_function, :class => 'icon icon-kill'
      end
    end

    def clear_status_icon_js
      "clearStatusIcon('#{status_icon_id}');"
    end

    def status_icon_id
      @status_icon_id ||= "new_#{@model}_remote_form_status"
    end
  end

  class GridBuilder
    attr_reader :template
    attr_reader :model
    attr_reader :columns

    def initialize(template, model, collection, options, block)
      @t = template
      @template = template
      @model = model.to_s
      @collection = collection
      @options = default_options.deep_merge(options)
      @columns = []
      block.call(self)
      # TODO: auto-generate columns when empty
      @new_record_form = NewRecordForm.new(self)

      @t.concat(@t.request.xhr? ? render_unwrapped : render)
    end

    def default_controller
      @model.pluralize
    end

    def default_url
      { :controller => default_controller, :action => 'index' }
    end

    def default_options
      { :submit_url => default_url,
        :reload_url => default_url,
        :show_title => true,
        :title => "Listing all #{@model.pluralize}",
        :html => {
          :id => "#{@model.pluralize}_grid",
          :class => "grid"
        },
        :show_header => true,
        :show_footer => true,
        :show_status => true,
        :show_edit => true,
        :show_destroy => true,
        :show_new_record_link => true,
        :new_record_link_title => "Enter new #{@model}",
        :destroy_confirmation => 'Are you sure?' }
    end

    def column(title = nil, html_options = {}, options = {}, &block)
      @columns << GridColumn.new(@t, title, html_options, options, block)
    end

    # TODO: pipe through macro
    def title(&block)
      @title_block = block
    end

    def setup_record(&block)
      @setup_record_block = block
    end

    def confirm_destroy(&block)
      @confirm_destroy_block = block
    end

    def destroy_link(&block)
      @destroy_link_block = block
    end

    def footer(&block)
      @footer_block = block
    end

    def pagination(&block)
      @pagination_block = block
    end

    def when_empty(&block)
      @when_empty_block = block
    end

    def submit_url
      @options[:submit_url]
    end

    def destroy_url(id)
      url = { :controller => default_controller, :action => 'destroy',
        :id => id, :page => @t.params[:page] }
    end

    # TODO: these reload params are getting really messy, clean them up!
    def reload_page_js(options = {})
      params = @t.params.clone
      params.merge!(@options[:reload_params]) if @options[:reload_params]
      params.merge!(options.delete(:params)) if options[:params]

      # TODO: couldn't we loop them in javascript instead?
      params_js = params.map{ |k,v| "encodeURIComponent('#{k}')+'='+encodeURIComponent('#{v}')" }.join("+'&'+")

      opts = { :update => wrapper_id,
        :url => @options[:reload_url],
        :method => :get,
        :with => params_js }.merge!(options)
      @t.remote_function(opts) + ";" + (@options[:after_reload] || "")
    end

    def grid_id
      @options[:html][:id]
    end

    def wrapper_id
      "#{grid_id}_wrapper"
    end

    def action_links_row_id
      @action_links_row_id ||= "#{grid_id}_action_links_row"
    end

    def new_record_link(title = nil, onclick_js = '')
      title ||= @options[:new_record_link_title]
      new_record_row_id = @new_record_form.form_row_id
      grid_action_links_row_id = action_links_row_id

      update_function = @t.update_page do |page|
        page[grid_action_links_row_id].hide
        page[new_record_row_id].show
        page[new_record_row_id].select('form').first.get_inputs.first.focus
      end

      @t.link_to_function title, update_function + ';' + onclick_js,
        :class => "grid-new-record-link"
    end

    def control_columns_count
      count = 0
      #count += 1 if @options[:show_status]
      count += 1 #if @options[:show_edit]
      count += 1 if @options[:show_destroy]
      count
    end

    def total_columns_count
      @columns.count + control_columns_count
    end

    protected

    def render
      @t.content_tag :div, :id => wrapper_id, :class => 'grid-wrapper' do
        render_unwrapped
      end
    end

    def render_unwrapped
      render_title + records_table
    end

    def render_title
      return "" unless @options[:show_title]

      @t.content_tag :div, :class => 'grid-title' do
        unless @title_block.nil?
          @title_block.call
        else
          @t.content_tag :h2, @options[:title]
        end
      end
    end

    def records_table
      @t.content_tag :table, @options[:html] do
        records_thead + records_tbody + records_tfoot
      end
    end

    def records_thead
      return "" unless @options[:show_header]

      @t.content_tag :thead do
        @t.content_tag :tr do
          #icon_th \
          #+
          @columns.map{|col| col.render_head}.join \
          + icon_th \
          + icon_th
        end
      end
    end

    def icon_th
      @t.content_tag :th do
        @t.content_tag :div, '', :class => 'icon'
      end
    end

    def records_tbody
      @t.content_tag :tbody do
        (action_rows + record_rows).join("\n")
      end
    end

    def action_rows
      return [] unless @options[:show_new_record_link] # || @options[:show_search_link]
      [action_links_row] + action_form_rows
    end

    def action_links_row
      options = { :id => action_links_row_id, :class => 'grid_actions' }
      options[:style] = 'display:none;' unless @t.params[:_grid_form].blank?
      @t.content_tag :tr, options do
        table_wide_td do
          new_record_link # + '|' + search_link
        end
      end
    end

    def table_wide_td
      @t.content_tag :td, :colspan => total_columns_count do
        yield
      end
    end

    def action_form_rows
      [@new_record_form.render_row] #, @search_record_form.render_row]
    end

    def record_rows
      unless @collection.empty?
        record_rows_from_collection
      else
        [empty_collection_banner] # for join
      end
    end

    def record_rows_from_collection
      @collection.map do |object|
        unless @setup_record_block.nil?
          @setup_record_block.call(object)
        else
          @t.instance_variable_set(:"@#{@model}", object)
        end

        record = RecordJSHelper.new(@t, @model, object,
                                    :reload_page_js => reload_page_js)

        @t.content_tag :tr, :id => record.row_id do
          #status_icon_td(record) \
          #+
          @columns.map{|col| col.render_cell(record)}.join \
          + edit_link_td(record) \
          + destroy_link_td(record)
        end
      end
    end

    def empty_collection_banner
      @t.content_tag :tr, :class => 'grid-empty-collection-banner' do
        table_wide_td do
          unless @when_empty_block.nil?
            @when_empty_block.call
          else
            @t.content_tag :h2, "Your list of #{@model.pluralize} is empty"
          end
        end
      end
    end

    def records_tfoot
      return "" unless @options[:show_footer]

      @t.content_tag :tfoot do
        records_footer + records_pagination
      end
    end
    
    def records_footer
      unless @footer_block.nil?
        @footer_block.call
      else
        ""
      end
    end

    def records_pagination
      unless @pagination_block.nil? || @collection.empty? || !@collection.respond_to?(:total_pages)
        @t.content_tag :tr do
          table_wide_td do
            @t.content_tag :div, :class => 'pagination-wrapper' do
              @pagination_block.call
            end
          end
        end
      else
        ""
      end
    end

    def status_icon_td(record)
      return "" unless @options[:show_status]

      @t.content_tag :td do
        status_icon(record)
      end
    end

    def status_icon(record)
      @t.content_tag :div, '', :class => 'icon', :id => record.status_icon_id
    end

    def edit_link_td(record)
      @t.content_tag :td do
        if @options[:show_edit]
          @t.link_to '', @t.send(:"edit_#{@model}_path", record.object),
            :class => "icon icon-edit"
        else
          status_icon(record)
        end
      end
    end

    def destroy_link_td(record)
      return "" unless @options[:show_destroy]

      @t.content_tag :td do
        reload_func = "function(){ #{reload_page_js} }"
        fade_js = @t.visual_effect(:fade, record.row_id,
                                   :duration => 0.25,
                                   :afterFinish => reload_func)
        opts = { :url => destroy_url(record.object.id),
          :method => :delete,
          :confirm => destroy_confirmation(record),
          :success => fade_js + ";" + (@options[:after_destroy] || "") }
        html_opts = { :class => "icon icon-kill" }

        unless @destroy_link_block.nil?
          @destroy_link_block.call('', opts, html_opts)
        else
          @t.link_to_remote '', record.ajax_options.merge(opts), html_opts
        end
      end
    end

    def destroy_confirmation(record)
      unless @confirm_destroy_block.nil?
        @confirm_destroy_block.call(record.object).strip
      else
        @options[:destroy_confirmation]
      end
    end

    class RecordJSHelper
      attr_reader :object, :reload_page_js

      def initialize(template, model, object, options = {})
        @t = template
        @model = model
        @object = object
        @status_icon_id = options[:status_icon_id]
        @reload_page_js = options[:reload_page_js]
      end

      def row_id
        "#{@model}_#{object.id}"
      end

      def status_icon_id
        @status_icon_id ||= "#{@model}_#{@object.id}_status"
      end

      def start_spinner_js
        "startSpinner('#{status_icon_id}');"
      end

      def dig_error_text_js
        <<EOF
var errorText = '';
if (typeof(transport) != 'undefined')
  errorText = transport.responseText;
else if (typeof(request) != 'undefined')
  errorText = request.responseText;
errorText = errorText.substring(0,256);
EOF
      end

      def set_icon_error_js
        "setStatusIcon('#{status_icon_id}','error',errorText);"
      end

      def failure_js
        dig_error_text_js + set_icon_error_js + "alert(errorText);"
      end

      def set_icon_normal_js
        "clearStatusIcon('#{status_icon_id}');"
      end

      def ajax_options
        { :loading => start_spinner_js,
          :saving => start_spinner_js,
          :failure => failure_js,
          :success => set_icon_normal_js }
      end
    end
  end
end
