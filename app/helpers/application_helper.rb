module ApplicationHelper
  def url_domain(url)
    URI.parse(url).host if url
  end

  def bootstrap_class_for flash_type
    { success: "success", error: "danger", alert: "warning", notice: "info" }[flash_type.to_sym] || flash_type.to_s
  end

  def full_title(page_title)
    full_title = "MightySignal"
    full_title += " | #{page_title}" unless page_title.blank?
  end

  def week_formatter(week)
    label = ""
    end_date = week + 6.days
    if (Date.today >= week) && (Date.today <= end_date)
      label += "This Week - "
    end
    label += week.strftime("%B #{week.day.ordinalize}")
    if week.year != end_date.year
      label += " #{week.year}"
    end
    label += ' - '
    if week.month != end_date.month
      label += end_date.strftime('%B ')
    end
    label += end_date.day.ordinalize
    if Date.today.year != end_date.year
      label += " #{end_date.year}"
    end
    label
  end
end
