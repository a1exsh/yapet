module ActivePopupHelper
  def popup(title, options = {}, &block)
    PopupBuilder.new(self, title, options, block)
  end

  protected

  class PopupBuilder
    def initialize(template, title, options, block)
      @t = template
      @title = title
      @options = default_options.merge(options)
      @block = block
      @t.concat(render)
    end

    def default_options
      { :class => 'popup-window',
        :style => 'display:none;' }
    end

    def appear_js(position_element_id, effect_options = {})
      popup_id = @options[:id]
      set_position_js = <<EOF
var popup = $('#{popup_id}');
var link = $('#{position_element_id}');
popup.style.position = 'absolute';
Element.clonePosition(popup, link, {
  setWidth: false,
  setHeight: false,
  offsetLeft: -Element.getWidth(popup)+Element.getWidth(link)
});
EOF
      effect_options[:duration] ||= 0.5
      set_position_js + @t.visual_effect(:appear, popup_id, effect_options)
    end

    def fade_js(effect_options = {})
      effect_options[:duration] ||= 0.25
      @t.visual_effect(:fade, @options[:id], effect_options)
    end

    protected

    def render
      @t.content_tag :div, @options do
        header_div + contents_div
      end
    end

    def header_div
      @t.content_tag :div, :class => 'window-header' do
        close_link + title_span
      end
    end

    def close_link
      @t.link_to_function '', fade_js,
        :class => 'window-icon window-icon-close'
    end

    def title_span
      @t.content_tag :span, @title, :class => 'window-title'
    end

    def contents_div
      @t.content_tag :div, :class => 'window-contents' do
        @block.call(self)
      end
    end
  end
end
