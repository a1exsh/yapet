module AutoComplete      
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  #
  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     auto_complete_for :post, :title
  #   end
  #
  #   # View
  #   <%= text_field_with_auto_complete :post, title %>
  #
  # By default, auto_complete_for limits the results to 10 entries,
  # and sorts by the given field.
  # 
  # auto_complete_for takes a third parameter, an options hash to
  # the find method used to search for the records:
  #
  #   auto_complete_for :post, :title, :limit => 15, :order => 'created_at DESC'
  #
  # For help on defining text input fields with autocompletion, 
  # see ActionView::Helpers::JavaScriptHelper.
  #
  # For more examples, see script.aculo.us:
  # * http://script.aculo.us/demos/ajax/autocompleter
  # * http://script.aculo.us/demos/ajax/autocompleter_customized
  module ClassMethods
    def auto_complete_for(object, method, options = {}, model_options = {})
      opts = { :object => object, :method => method }.merge!(model_options)

      define_method("auto_complete_for_#{object}_#{method}") do
        search = params[:value] || params[object][method]
        unless search == "?"
          conditions = ["LOWER(\' \' || #{opts[:method]}) LIKE ?",
                        '% ' + search.mb_chars.downcase.to_s + '%']
        end
        find_options = { :conditions => conditions,
          :order => "#{opts[:method]} ASC",
          :limit => 10 }.merge!(options)

        scope = opts[:scope]
        scope = case scope
                when Proc;      scope.call(self)
                when Symbol;    self.send(scope)
                when nil.class; opts[:object].to_s.camelize.constantize
                end
        @items = scope.find(:all, find_options)

        render :inline => "<%= auto_complete_result @items, '#{opts[:method]}' %>"
      end
    end
  end
  
end
