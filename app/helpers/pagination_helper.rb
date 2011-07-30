module PaginationHelper
  def paginate_with_settings(collection, options = {})
    model = controller_name.singularize
    builder = PaginationBuilder.new(self, model, collection, options)
  end

  protected

  class PaginationBuilder
    def initialize(template, model, collection, options = {})
      @t = template
      @model = model
      @collection = collection
      @options = default_options.deep_merge(options)
      @t.concat(render)
    end

    def default_options
      { :paginate => default_pagination_options,
        :settings => default_settings_options }
    end

    def default_pagination_options
      { :params => { :controller => @model.pluralize, :action => 'index' },
        :previous_label => _("&laquo;&nbsp;Prev."),
        :next_label => _("Next&nbsp;&raquo;") }
    end

    def default_settings_options
      { :title => _("Settings"),
        :html => { :id => 'pagination_settings_window' },
        :success => '' }
    end

    def render
      @popup = settings_window
      settings_link + pagination_div
    end

    protected

    def settings_link
      link_id = "pagination_settings_link"
      @t.link_to_function '', @popup.appear_js(link_id),
        :class => "icon icon-settings pagination-settings-icon",
        :id => link_id
    end

    def pagination_div
      (@t.will_paginate @collection, @options[:paginate]) || ''
    end

    def settings_window
      form_id = 'pagination_settings_form'
      @t.popup @options[:settings][:title], @options[:settings][:html] do |p|
        @t.remote_form_for @t.current_user,
          :url => { :controller => :settings, :action => :update },
          :loading => "startSpinner('#{form_id}');",
          :complete => "stopSpinner('#{form_id}');" + p.fade_js,
          :success => @options[:settings][:success],
          :html => { :id => form_id } do |f|

          @t.concat f.label(:records_per_page, _("Records per Page:"))
          @t.concat '&nbsp;'
          @t.concat f.select(:records_per_page, @t.pagination_choices, {},
                             :onchange => "submitForm('#{form_id}');")
        end
      end
    end
  end
end
