module InPlaceCustomizationHelper
  def in_place_customization_options
    customize_form_js = <<EOF
var ok_link = document.createElement('a');
ok_link.href = '#';
ok_link.className = 'editor_ok_link';
ok_link.onclick = ipe._boundSubmitHandler;
form.appendChild(ok_link);
EOF
    enter_edit_mode_js = <<EOF
if (typeof(_grid_active_inplace_editor) != 'undefined' && _grid_active_inplace_editor != null)
  _grid_active_inplace_editor._boundCancelHandler();
_grid_active_inplace_editor = ipe;
EOF
    { :cancel_text => "",
      :customize_form => customize_form_js,
      :enter_edit_mode => enter_edit_mode_js }
#      :cancel_on_blur => true
  end
end
