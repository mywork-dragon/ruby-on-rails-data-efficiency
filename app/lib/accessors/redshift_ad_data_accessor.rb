class RedshiftAdDataAccessor

  def query(
    platforms:['ios', 'android'],
    source_ids: [],
    sort_by: 'first_seen_ads_date',
    order_by: 'desc',
    page_size: 20,
    page_number:0)
    # Filters and sorts apps by ad intel data.
    # Params:
    #   platforms: The platforms to filter this query by.
    #   sort_by: A field to sort the result set by one of first_seen_ads_date, last_seen_ads_date or user_base_display_score.
    #   order_by: Order by asc or desc,
    #   source_ids: A list of source_ids from available_sources to which this query applies to nil => all supported.
    # Returns:
    # See AdDataAccessor

    platforms_sql = ""

    if platforms.count != AdDataPermissions::APP_PLATFORMS.count
      platforms_sql = "AND apps.platform in ('#{platforms.join("','")}')"
    end
    source_ids_sql = "AND mobile_ad_data_summaries.ad_network in ('#{source_ids.join("','")}')"

    if ![nil, 'first_seen_ads_date', 'last_seen_ads_date', 'user_base_display_score'].include? sort_by
      raise "Unsupported sort_by option"
    end
    if ![nil, 'desc', 'asc'].include? order_by
      raise "Unsupported order_by option"
    end

    if !sort_by.nil?
      sort_by_sql = "ORDER BY #{sort_by}"
      if !order_by.nil?
        sort_by_sql = "#{sort_by_sql} #{order_by}"
      end
    end

    limit_sql = "LIMIT #{page_size}"
    offset = page_size * page_number
    offset_sql = "OFFSET #{offset}"

    sql = "
      SELECT apps.id,
             apps.name,
             apps.platform,
             apps.primary_category,
             apps.categories,
             not BOOL_OR(apps.taken_down) as available,
             apps.user_base_score as user_base_display_score,
             apps.user_base,
             apps.icon_url,
             apps.publisher_id,
             apps.publisher_name,
             min(mobile_ad_data_summaries.first_seen_ads_date) AS first_seen_ads_date,
             datediff(DAY, min(mobile_ad_data_summaries.first_seen_ads_date)::TIMESTAMP, GETDATE()) AS first_seen_ads_days,
             max(mobile_ad_data_summaries.last_seen_ads_date) AS last_seen_ads_date,
             datediff(DAY, max(mobile_ad_data_summaries.last_seen_ads_date)::TIMESTAMP, GETDATE()) AS last_seen_ads_days,
             listagg(DISTINCT mobile_ad_data_summaries.ad_network, ',') AS ad_networks,
             listagg(DISTINCT mobile_ad_data_summaries.ad_formats, ',') AS ad_formats,
             count(*) OVER() AS full_count
      FROM mobile_ad_data_summaries,
           apps
      WHERE mobile_ad_data_summaries.app_identifier = apps.app_identifier
        AND mobile_ad_data_summaries.platform = apps.platform 
        #{platforms_sql}
        #{source_ids_sql}
      GROUP BY apps.id,
               apps.name,
               apps.platform,
               apps.primary_category,
               apps.categories,
               apps.user_base_score,
               apps.user_base,
               apps.icon_url,
               apps.publisher_id,
               apps.publisher_name
      #{sort_by_sql}
      #{limit_sql}
      #{offset_sql}
      "
    results = RedshiftBase.query(sql, expires: 15.minutes).fetch
    output = []
    full_count = 0

    results.each do |app|
      full_count = app['full_count']
      if app['categories']
        categories = JSON.parse(app['categories']).values
        categories.each do |cat|
          if cat['id'].nil?
            cat['id'] = cat['name']
          end
        end 
      else
        categories = {}
      end
      output.append(
      {
      'id' => app['id'],
      'name' =>  app['name'],
      'platform' =>  app['platform'],
      'app_available' => app['available'],
      'categories' => categories,
      'user_base_display_score' =>  app['user_base_display_score'],
      'user_base' => app['user_base'],
      'icon' => app['icon_url'],
      'publisher' =>  {"id" => app['publisher_id'], "name" => app['publisher_name']},
      'first_seen_ads_date' => app['first_seen_ads_date'],
      'first_seen_ads_days' => app['first_seen_ads_days'],
      'last_seen_ads_date' => app['last_seen_ads_date'],
      'last_seen_ads_days' => app['last_seen_ads_days'],
      'ad_attribution_sdks' => "#{app['platform']}_app".classify.constantize.find(app['id']).ad_attribution_sdks,
      'ad_formats' => Set.new(app['ad_formats'].split(',')).to_a.map{|x| {"id" => x, "name" => x.split('_').map{|x| x.capitalize}.join(" ")}},
      'ad_sources' => app['ad_networks'].split(',').map {|network_id| {"id" => network_id}}
      })
    end
    return output, full_count
  end
end
