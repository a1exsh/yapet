module UserAgentHelper
  def webkit_user_agent?
    request.env["HTTP_USER_AGENT"] =~ /WebKit/
  end

  def gecko_user_agent?
    request.env["HTTP_USER_AGENT"] =~ /Gecko\//
  end

  def chrome_user_agent?
    request.env["HTTP_USER_AGENT"] =~ /Chrome\//
  end

  def windows_user_agent?
    request.env["HTTP_USER_AGENT"] =~ /Windows/
  end

  def unix_user_agent?
    request.env["HTTP_USER_AGENT"] =~ /X11/
  end

  def user_agent_tweaks
    # check webkit first, as it might issue 'like Gecko' in the header
    if webkit_user_agent?
      stylesheet_link_tag 'webkit'
    elsif gecko_user_agent?
      stylesheet_link_tag 'gecko'
    end
  end

  def user_agent_choices
    choices = [{ :id => "firefox",
                 :class => "firefox",
                 :browser => _("Firefox"),
                 :os => _("Any OS"),
                 :detected => gecko_user_agent? },
               { :id => "chrome_any",
                 :class => "chrome",
                 :browser => _("Chrome"),
                 :os => _("Any OS"),
                 :detected => chrome_user_agent? && !unix_user_agent? },
               { :id => "safari",
                 :class => "safari",
                 :browser => _("Safari"),
                 :os => _("Any OS"),
                 :detected => webkit_user_agent? && !chrome_user_agent? },
               { :id => "chrome_x11",
                 :class => "chrome",
                 :browser => _("Chrome"),
                 :os => _("Unix-like"),
                 :detected => chrome_user_agent? && unix_user_agent? },
               { :id => "other",
                 :class => "other",
                 :browser => _("Other"),
                 :os => _("Other"),
                 :detected => false }]
    choices.last[:detected] = !choices.detect{ |c| c[:detected] }
    choices
  end
end
