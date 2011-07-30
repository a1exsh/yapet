module InPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for :post, :title
  #   end
  #
  #   # View
  #   <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    def in_place_edit_for(object, method, options = {})
      define_method("set_#{object}_#{method}") do
        @item = object.to_s.camelize.constantize.find(params[:id])
        @item.update_attributes!(method => params[:value])
        render :text => @item.send(method)
      end
    end
  end
end
