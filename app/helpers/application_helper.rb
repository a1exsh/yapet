# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def cy(amount)
    amount = (amount || 0).to_f
    if amount < 100
      "%.2f" % amount
    else
      content_tag :span, :class => "cy", :title => ("%.2f" % amount) do
        if amount < 9999.50
          "%.0f" % amount.round
        elsif amount < 999950
          "%.1fk" % (amount/1000)
        else
          "%.1fM" % (amount/1_000_000)
        end
      end
    end
  end

  ######################################################################

  def pagination_choices
    [5, 10, 15, 20, 25, 50]
  end

  def locale_choices
    @locales_with_names
  end

  ######################################################################

  def external_link_to(*args, &block)
    if block_given?
      link_to(args.first || {},
              html_options_for_external_link(args.second)) { block.call }
    else
      link_to args.first, (args.second || {}),
        html_options_for_external_link(args.third)
    end
  end

  def html_options_for_external_link(html)
    html ||= {}
    html.merge(:target => "_blank", :class => "bgicon external")
  end

  ######################################################################

  def text_field_with_arithmetic_tag(name, value = nil, options = {})
    tag_id = options[:id] || name
    add_calculate_input_on_change_option(tag_id, options)
    text_field_tag(name, value, options)
  end

  def text_field_with_arithmetic(object_name, method, options = {})
    tag_id = options[:id] || "#{object_name}_#{method}"
    add_calculate_input_on_change_option(tag_id, options)
    text_field(object_name, method, options)
  end

  def add_calculate_input_on_change_option(tag_id, options)
    onchange = options[:onchange] || ""
    onchange += ";" unless onchange.blank?
    onchange += "calculate_input_for_id('#{tag_id}');"
    options[:onchange] = onchange
  end
end
