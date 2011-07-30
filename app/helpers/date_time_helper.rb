module DateTimeHelper
  def date_or_time_ago_in_words(time)
    diff = Time.zone.now - time
    if diff < 30.seconds
      _("Moments ago")
    elsif diff < 8.hours
      _("%s ago") % time_ago_in_words(time).mb_chars.capitalize.to_s
    elsif today?(time)
      _("Today")
    elsif yesterday?(time)
      _("Yesterday")
    else
      localize time.to_date, :format => time_format_for_diff(diff)
    end
  end

  def today?(time)
    time.to_date == Time.zone.now.to_date
  end

  def yesterday?(time)
    today?(time + 1.day)
  end

  def time_tooltip_text(time)
    localize time, :format => time_format_for_diff(Time.zone.now - time)
  end

  def time_format_for_diff(diff)
    diff < 1.year/2 ? :short : "%F"
  end
end
