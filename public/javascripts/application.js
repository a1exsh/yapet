function onLoad()
{
  focusOnLoginForm() || focusOnPasswordRequestForm();
}

function focusOnLoginForm()
{
  var login_form = $('login_form');
  if (login_form) {
    var els = Element.select(login_form, '#email');
    if (els && els.length > 0) {
      var email = els[0];
      if (!Element.readAttribute(email, "value"))
        email.focus();
      else {
        els = Element.select(login_form, '#password');
        if (els && els.length > 0)
          els[0].focus();
      }
    }
    return true;
  }
}

function focusOnPasswordRequestForm()
{
  var pw_form = $('pw_request_form');
  if (pw_form) {
    var els = Element.select(pw_form, '#email');
    if (els && els.length > 0) {
      var email = els[0];
      email.focus();
    }
  }
}

function submitForm(id)
{
  try {
    var form = $(id);
    form.onsubmit.bind(form);
    form.onsubmit();
  } catch(e) {}
}

function checkPasswordConfirmation(pwid)
{
  if (pwid == null)
    pwid = 'new_password';
  if ($('confirm_password').value != ""
      && $(pwid).value != $('confirm_password').value) {
    setStatusIcon('password-match-status', 'error');
  } else {
    clearStatusIcon('password-match-status');
    setStatusIcon('password-match-status', 'ok');
  }
}

////////////////////////////////////////////////////////////////////////

function startSpinner(id)
{
  $(id).addClassName('status-spinner');
}

function stopSpinner(id)
{
  $(id).removeClassName('status-spinner');
}

function setStatusIcon(id, status, message)
{
  stopSpinner(id);

  var element = $(id);
  element.addClassName('status-' + status);
  element.title = typeof(message) == "undefined" ? "" : message;
}

function clearStatusIcon(id)
{
  stopSpinner(id);

  var element = $(id);
  element.removeClassName('status-error');
  element.title = "";
}

////////////////////////////////////////////////////////////////////////

function hide_guide(toggle_func, show_text, hide_text) {
  toggle_func();
  $('expenses_guide').blindUp({ duration: 0.5 });
  $('toggle_guide').innerHTML = show_text;
  $('toggle_guide').onclick = function() {
    show_guide(toggle_func, show_text, hide_text);
    return false;
  }
}

function show_guide(toggle_func, show_text, hide_text) {
  toggle_func();
  $('expenses_guide').blindDown({ duration: 0.5 });
  $('toggle_guide').innerHTML = hide_text;
  $('toggle_guide').onclick = function() {
    hide_guide(toggle_func, show_text, hide_text);
    return false;
  }
}

////////////////////////////////////////////////////////////////////////

function calculate_input(element)
{
  var value = element.value;
  if (value == null || value == "") {
    element.removeClassName("input-error");
  } else if (value.match(/[+\-*\/]/) && value.match(/[0-9.,+\-*\/()]+/)) {
    try {
      element.value = eval(value).toFixed(2);
      element.removeClassName("input-error");
    } catch(e) {
      element.addClassName("input-error");
    }
  }
}

function calculate_input_for_id(id)
{
    calculate_input($(id));
}
