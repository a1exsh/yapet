module LocaleHandling
  protected # we don't want our methods to slip into controller actions

  def with_locale(new_locale)
    original_locale = I18n.locale
    I18n.locale = new_locale
    yield
  ensure
    I18n.locale = original_locale
  end
end
