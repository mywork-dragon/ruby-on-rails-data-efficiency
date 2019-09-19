module ApplicationHelper
  def url_domain(url)
    URI.parse(url).host if url
  end

  def bootstrap_class_for flash_type
    { success: "success", error: "danger", alert: "warning", notice: "info" }[flash_type.to_sym] || flash_type.to_s
  end

  # Highlight link if current page is the link destination
  def nav_link(link_text, link_path, html_options = {})
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, :class => ['nav-item']) do
      link_to link_text, link_path, class: html_options[:class] || 'nav-link ' + class_name
    end
  end

  def full_title(page_title)
    full_title = "Mobile App and SDK Intelligence for iOS and Android"
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

  def header_styles
    browser.device.mobile? ? 'navbar-expand-lg' : 'navbar-expand-md fixed-top'
  end

  def blog_container_styles
    browser.device.mobile? ? 'blog-container-mobile' : 'blog-container-tablet'
  end

  def heading_margin_normalize
    browser.device.mobile? ? '' : 'heading-margin-normalize'
  end

  def free_data_margin_normalize
    !browser.device.mobile? && (free_data_pages? || not_found_page?) ? 'free-data-margin-normalize' : ''
  end

  def jumbotron_mobile
    browser.device.mobile? ? 'jumbotron-mobile' : ''
  end

  def calculate_percentage_change(array)
    (array.last.last.to_f-array.first.last.to_f)/array.last.last.to_f
  rescue
    0.0
  end
  
  def pretty_platform(platform)
    platform == 'ios' ? 'iOS' : 'Android'
  end
  
  private
  
  def free_data_pages?
    %w(ios_app_sdks fastest_growing_sdks top_ios_apps top_ios_sdks top_android_apps top_android_sdks timeline).include?(action_name)
  end

  def not_found_page?
    %w(internal_error not_found).include?(action_name)
  end

  def sdk_list_item_params(item, input_data_type, platform)
    case input_data_type
    when 'app'
      OpenStruct.new({
                         item: item,
                         path: app_page_path(platform, item.app_identifier),
                         target: '_blank',
                         icon: item.icon_url
                     })
    when 'sdk'
      OpenStruct.new({
                         item: item,
                         path: sdk_page_path(platform, item.id, item.name.parameterize),
                         target: '_blank',
                         icon: "https://ui-avatars.com/api/?background=64c5e0&color=fff&name=#{item.name.parameterize}"
                     })
    when 'array-sdk'
      begin 
        item_object = "#{platform.capitalize}Sdk".constantize.find(item) 
        OpenStruct.new({
                           item: item_object,
                           path: sdk_page_path(platform, item_object.id, item_object.name.parameterize),
                           target: '',
                           icon: "https://ui-avatars.com/api/?background=64c5e0&color=fff&name=#{item_object.name.parameterize}"
                       })
      rescue ActiveRecord::RecordNotFound
        false
      end
    else
      false
    end
  end
end
