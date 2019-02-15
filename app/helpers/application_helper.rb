module ApplicationHelper
  def url_domain(url)
    URI.parse(url).host if url
  end

  def bootstrap_class_for flash_type
    { success: "success", error: "danger", alert: "warning", notice: "info" }[flash_type.to_sym] || flash_type.to_s
  end

  # Highlight link if current page is the link destination
  def nav_link(link_text, link_path, html_options = {})
    class_name = current_page?(link_path) ? 'active' : nil

    content_tag(:li, :class => [class_name, 'nav-item']) do
      link_to link_text, link_path, class: html_options[:class] || 'nav-link'
    end
  end

  def full_title(page_title)
    full_title = "MightySignal - Mobile App & SDK Intelligence for iOS / Android"
    full_title = "#{page_title} | #{full_title}" unless page_title.blank?
    full_title.html_safe
  end

  def og_image_url(url)
    if url.present?
      url
    else
      'https://mightysignal.com/app/app/images/mighty_signal_logo.png'
    end
  end
  
  def meta_description(meta_description)
    meta_description.present? ? "#{meta_description}" : "MightySignal is the leader in SDK intelligence and provides access to the largest database of relationships between mobile apps and the software development kits (SDKs) they install and uninstall"
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
