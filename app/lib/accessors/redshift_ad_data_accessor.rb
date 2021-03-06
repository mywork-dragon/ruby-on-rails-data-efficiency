class RedshiftAdDataAccessor

  def initialize(connection: nil)
    @connection = connection || RedshiftDbConnection.new
  end

  def has_ad_spend_data(
    app_identifier,
    platform,
    source_ids: nil
    )
    pb = RedshiftDbConnection::ParamsBuilder.new
    sql = "
            SELECT 1
            FROM mobile_ad_data_summaries
            WHERE mobile_ad_data_summaries.app_identifier = #{pb.add_param(app_identifier)}
              AND mobile_ad_data_summaries.platform = #{pb.add_param(platform)}
              AND mobile_ad_data_summaries.ad_network in (#{pb.add_params(source_ids)})
            LIMIT 1
    "
    !@connection.query(sql, params: pb.params, expires: 15.minutes).fetch.empty?
  end

  def fetch_all_app_summaries(
    platforms: nil,
    source_ids: nil,
    sort_by: 'app_identifier',
    order_by: 'desc',
    page_size: 20,
    page_number:0
    )
    pb = RedshiftDbConnection::ParamsBuilder.new

    where_clauses = []
    where_clauses << "mobile_ad_data_summaries.platform in (#{pb.add_params(platforms)})" if platforms && platforms.any?
    where_clauses << "mobile_ad_data_summaries.ad_network in (#{pb.add_params(source_ids)})" if source_ids && source_ids.any?
    where_clause_string = where_clauses.any? ? " WHERE #{where_clauses.compact.join(' AND ')} " : ""

    sql = "
            SELECT mobile_ad_data_summaries.app_identifier,
                   mobile_ad_data_summaries.platform,
                   min(first_seen_ads_date) AS first_seen_ads_date,
                   max(last_seen_ads_date) AS last_seen_ads_date,
                   LISTAGG(DISTINCT mobile_ad_creative_summaries.format, ',') AS creative_formats,
                   LISTAGG(DISTINCT mobile_ad_data_summaries.ad_formats, ',') AS ad_formats,
                   count(mobile_ad_creative_summaries.url) AS number_of_creatives,
                   mobile_ad_data_summaries.ad_network AS ad_network,
                   count(*) OVER() AS full_count
            FROM mobile_ad_data_summaries
            LEFT JOIN mobile_ad_creative_summaries ON mobile_ad_creative_summaries.platform = mobile_ad_data_summaries.platform
            AND mobile_ad_creative_summaries.app_identifier = mobile_ad_data_summaries.app_identifier
            AND mobile_ad_creative_summaries.ad_network = mobile_ad_data_summaries.ad_network
            #{where_clause_string}
            GROUP BY mobile_ad_data_summaries.app_identifier,
                     mobile_ad_data_summaries.platform,
                     mobile_ad_data_summaries.ad_network
            ORDER BY #{sort_by}
            LIMIT #{page_size}
            OFFSET #{page_number * page_size};
    "

    results = @connection.query(sql, params: pb.params, expires: 15.minutes).fetch
    full_count = 0
    if results.count > 0
      full_count = results[0]['full_count']
    end
    results.each do |result|
      result.delete('full_count')
    end
    return results, full_count
  end

  def fetch_app_summaries(
    app_identifiers,
    platform,
    source_ids: nil
    )
    pb = RedshiftDbConnection::ParamsBuilder.new
    sql = "
            SELECT mobile_ad_data_summaries.app_identifier,
                   mobile_ad_data_summaries.platform,
                   min(first_seen_ads_date) AS first_seen_ads_date,
                   max(last_seen_ads_date) AS last_seen_ads_date,
                   LISTAGG(DISTINCT mobile_ad_creative_summaries.format, ',') AS creative_formats,
                   LISTAGG(DISTINCT mobile_ad_data_summaries.ad_formats, ',') AS ad_formats,
                   count(mobile_ad_creative_summaries.url) AS number_of_creatives,
                   mobile_ad_data_summaries.ad_network AS ad_network
            FROM mobile_ad_data_summaries
            LEFT JOIN mobile_ad_creative_summaries ON mobile_ad_creative_summaries.platform = mobile_ad_data_summaries.platform
            AND mobile_ad_creative_summaries.app_identifier = mobile_ad_data_summaries.app_identifier
            AND mobile_ad_creative_summaries.ad_network = mobile_ad_data_summaries.ad_network
            WHERE mobile_ad_data_summaries.app_identifier in (#{pb.add_params(app_identifiers)})
              AND mobile_ad_data_summaries.platform = #{pb.add_param(platform)}
              AND mobile_ad_data_summaries.ad_network in (#{pb.add_params(source_ids)})
            GROUP BY mobile_ad_data_summaries.app_identifier,
                     mobile_ad_data_summaries.platform,
                     mobile_ad_data_summaries.ad_network;
    "

    @connection.query(sql, params: pb.params, expires: 15.minutes).fetch
  end

  def fetch_creatives(
    app_identifiers,
    platform,
    source_ids: nil,
    formats: nil,
    first_seen_creative_date: nil,
    last_seen_creative_date: nil,
    sort_by: 'first_seen_creative_date',
    order_by: 'desc',
    page_size: 20,
    page_number:0)

    pb = RedshiftDbConnection::ParamsBuilder.new

    if ![nil, 'count', 'first_seen_creative_date', 'last_seen_creative_date'].include? sort_by
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

    first_seen_creative_date_sql = ""
    if !first_seen_creative_date.nil?
      first_seen_creative_date_sql = "AND first_seen_creative_date > #{pb.add_param(first_seen_creative_date)}"
    end

    last_seen_creative_date_sql = ""
    if !last_seen_creative_date.nil?
      last_seen_creative_date_sql = "AND last_seen_creative_date > #{pb.add_param(last_seen_creative_date)}"
    end

    format_sql = ""
    if !formats.nil?
      format_sql = "AND format in (#{pb.add_params(formats)})"
    end

    sql = "
      SELECT last_seen_creative as last_seen_creative_date,
             first_seen_creative as first_seen_creative_date,
             app_identifier,
             ad_network,
             platform,
             format,
             url,
             \"count\",
             count(*) OVER() AS full_count
      FROM mobile_ad_creative_summaries
      WHERE 
        app_identifier in (#{pb.add_params(app_identifiers)})
        AND platform = #{pb.add_param(platform)}
        AND ad_network in (#{pb.add_params(source_ids)})
        #{format_sql}
        #{first_seen_creative_date_sql}
        #{last_seen_creative_date_sql}
      #{sort_by_sql}
      #{limit_sql}
      #{offset_sql}
    "
    results = @connection.query(sql, params: pb.params, expires: 15.minutes).fetch
    full_count = 0
    if results.count > 0
      full_count = results[0]['full_count']
    end
    results.each do |result|
      result.delete('full_count')
    end
    return results, full_count
  end


  def query(
    platforms:['ios', 'android'],
    source_ids: [],
    visible_source_ids: [],
    first_seen_ads_date: nil,
    last_seen_ads_date: nil,
    sort_by: 'first_seen_ads_date',
    order_by: 'desc',
    page_size: 20,
    page_number:0,
    extra_fields:[])
    # Filters and sorts apps by ad intel data.
    # Params:
    #   platforms: The platforms to filter this query by.
    #   sort_by: A field to sort the result set by one of first_seen_ads_date, last_seen_ads_date or user_base_display_score.
    #   order_by: Order by asc or desc,
    #   source_ids: A list of source_ids from available_sources to which this query applies to nil => all supported.
    # Returns:
    # See AdDataAccessor
    pb = RedshiftDbConnection::ParamsBuilder.new

    platforms_sql = nil

    if platforms.count != AdDataPermissions::APP_PLATFORMS.count
      platforms_sql = "mobile_ad_data_summaries.platform in (#{pb.add_params(platforms)})"
    end
    source_ids_sql = "mobile_ad_data_summaries.ad_network in (#{pb.add_params(source_ids)})"

    where_clauses = [platforms_sql, source_ids_sql]
    if ! first_seen_ads_date.nil?
      where_clauses.append("first_seen_ads_date > #{pb.add_params(first_seen_ads_date)}")
    end
    if ! last_seen_ads_date.nil?
      where_clauses.append("last_seen_ads_date > #{pb.add_params(last_seen_ads_date)}")
    end

    where_sql = where_clauses.compact.join(" AND ")

    if ![nil, 'first_seen_ads_date', 'last_seen_ads_date', 'user_base_display_score'].include? sort_by
      raise "Unsupported sort_by option"
    end
    if sort_by == 'user_base_display_score'
      sort_by = 'user_base_score'
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

    enabled_network_sql = "mobile_ad_data_summaries.ad_network in (#{pb.add_params(visible_source_ids)})"

    limit_sql = "LIMIT #{page_size}"
    offset = page_size * page_number
    offset_sql = "OFFSET #{offset}"
    extra_fields_sql = (extra_fields.map{|f, as_f| "#{f} as #{as_f}"} + [""]).join(",")
    sql = "
        WITH selected_apps as (
          select app_identifier from mobile_ad_data_summaries where #{where_sql}
        ),
        advertised_apps as (
        SELECT
            mobile_ad_data_summaries.app_identifier,
            platform,
            min(mobile_ad_data_summaries.first_seen_ads_date) AS first_seen_ads_date,
            datediff(DAY,
            min(mobile_ad_data_summaries.first_seen_ads_date)::TIMESTAMP,
            GETDATE()) AS first_seen_ads_days,
            max(mobile_ad_data_summaries.last_seen_ads_date) AS last_seen_ads_date,
            datediff(DAY,
            max(mobile_ad_data_summaries.last_seen_ads_date)::TIMESTAMP,
            GETDATE()) AS last_seen_ads_days,
            listagg(DISTINCT mobile_ad_data_summaries.ad_network,
            ',') AS ad_networks,
            listagg(DISTINCT mobile_ad_data_summaries.ad_formats,
            ',') AS ad_formats
        FROM
            mobile_ad_data_summaries, selected_apps
            WHERE
            mobile_ad_data_summaries.app_identifier = selected_apps.app_identifier
            AND #{enabled_network_sql}
        GROUP BY
            mobile_ad_data_summaries.app_identifier, platform
        )
        select
            #{extra_fields_sql}
            advertised_apps.app_identifier,
            advertised_apps.platform,
            advertised_apps.first_seen_ads_date,
            advertised_apps.first_seen_ads_days,
            advertised_apps.last_seen_ads_date,
            advertised_apps.last_seen_ads_days,
            advertised_apps.ad_networks,
            advertised_apps.ad_formats,
            count(*) OVER() AS full_count
        from apps, advertised_apps where apps.app_identifier = advertised_apps.app_identifier
        AND apps.platform = advertised_apps.platform
        #{sort_by_sql}
        #{limit_sql}
        #{offset_sql}
      "
    results = @connection.query(sql, params: pb.params, expires: 15.minutes).fetch
    full_count = 0
    if results.count > 0
      full_count = results[0]['full_count']
    end
    results.each do |result|
      result.delete('full_count')
    end
    return results, full_count
  end
end
