# TODO: Beware, people are likely to kill those who name functions
# like that!
#
module InPlaceEditingGridHelper
  include InPlaceMacrosHelper
  include InPlaceCompleterHelper
  include AutoCompleteMacrosHelper

  def self.included(target)
    target.alias_method_chain(:in_place_editor_field,
                              :customization)
    target.alias_method_chain(:in_place_completing_editor_field,
                              :customization)
    target.alias_method_chain(:text_field_with_auto_complete,
                              :skip_style)
  end

  def in_place_editor_field_with_customization(object, method, tag_opts = {},
                                               editor_opts = {})
    options = process_editor_options(editor_opts)
    in_place_editor_field_without_customization(object, method, tag_opts,
                                                options)
  end

  def in_place_completing_editor_field_with_customization(object,
                                                          method,
                                                          tag_opts = {},
                                                          editor_opts = {},
                                                          completion_opts = {})
    options = process_editor_options(editor_opts)
    in_place_completing_editor_field_without_customization(object, method, tag_opts, options, options_for_completer(completion_opts))
  end

  def in_place_editor_grid_field(grid_record, object, method, tag_options = {},
                                 in_place_editor_options = {})
    options = grid_editor_options(grid_record, in_place_editor_options)

    in_place_editor_field_without_customization(object, method, tag_options,
                                                options)
  end

  def in_place_completing_editor_grid_field(grid_record, object, method,
                                            tag_options = {},
                                            in_place_editor_options = {},
                                            completion_options = {})
    options = grid_editor_options(grid_record, in_place_editor_options)
    completion_options = options_for_completer(completion_options)

    in_place_completing_editor_field_without_customization(object, method,
                                                           tag_options, options,
                                                           completion_options)
  end

  def in_place_editor_field_with_arithmetic(object, method, tag_opts = {},
                                            editor_opts = {})
    editor_opts = editor_opts.merge(options_for_field_arithmetic)
    in_place_editor_field_with_customization(object, method, tag_opts,
                                             editor_opts)
  end

  def in_place_editor_grid_field_with_arithmetic(grid_record, object, method,
                                                 tag_options = {},
                                                 editor_opts = {})
    editor_opts = editor_opts.merge(options_for_field_arithmetic)
    options = grid_editor_options(grid_record, editor_opts)

    in_place_editor_field_without_customization(object, method, tag_options,
                                                options)
  end

  def text_field_with_auto_complete_with_skip_style(object, method,
                                                    tag_options = {},
                                                    completion_options = {})
    completion_options = options_for_completer(completion_options)
    text_field_with_auto_complete_without_skip_style(object, method,
                                                     tag_options,
                                                     completion_options)
  end

  protected

  def default_editor_options
    in_place_i18n_options.merge(in_place_customization_options)
  end

  def process_editor_options(options)
    default_options = default_editor_options
    process_status_icon_options(options)

    process_final_options_merge(default_options, options)
  end

  def process_status_icon_options(options)
    status_icon_id = options[:status_icon_id]
    unless status_icon_id.blank?
      reload_js = options[:reload_js] || ""

      saving_js = "startSpinner('#{status_icon_id}');"
      success_js = "stopSpinner('#{status_icon_id}');" + reload_js
      failure_js = <<EOF
var errorText = transport.responseText.substring(0, 256);
setStatusIcon('#{status_icon_id}', 'error', errorText);
alert(errorText);
EOF
      options.merge!(:saving => saving_js,
                     :success => success_js,
                     :failure => failure_js)
    end
  end

  def process_final_options_merge(default_options, options)
    # TODO: this is messy, to say the least
    customize_form_js = options.delete(:customize_form)
    options = default_options.merge(options)
    options[:customize_form] += ";" + customize_form_js unless customize_form_js.blank?
    options
  end

  def grid_editor_options(grid_record, in_place_editor_options)
    options = default_editor_options
    options.merge!(grid_record.ajax_options)
    options.merge!(:success => grid_record.reload_page_js)

    process_final_options_merge(options, in_place_editor_options)
  end

  def options_for_field_arithmetic
    {
      :customize_form => <<EOF
var editor = ipe._controls.editor;
editor.onchange = function() { calculate_input(editor) };
EOF
    }
  end

  def options_for_completer(completion_options)
    completion_options.merge(:skip_style => true)
  end
end
