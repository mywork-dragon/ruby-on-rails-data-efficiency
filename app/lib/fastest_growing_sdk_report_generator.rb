class FastestGrowingSdkReportGenerator
  def _fetch(relative)
    if relative
      relative_clause = "/ install_base_count"
    else
      relative_clause
    end
    sql = "
      SELECT sdk, sdk_install_bases.month,install_base_count, derivative_of_install_base_count
      FROM sdk_install_bases
      WHERE sdk IN
        (SELECT sdk
         FROM sdk_install_bases
         WHERE
            install_base_count > 10
            AND sdk_install_bases.month <= dateadd('month', -2, getdate())
            AND sdk NOT IN ('Firebase')
         GROUP BY sdk
         ORDER BY max(derivative_of_install_base_count #{relative_clause}) DESC LIMIT 100)
      AND sdk_install_bases.month <= dateadd('month', -2, getdate())
      ORDER BY month;
    "
    RedshiftDbConnection.new.query(sql).fetch
  end

  def _transform(data)
    # Group rows (sdk, sdk_install_bases.month,install_base_count, derivative_of_install_base_count) by sdk
    sdks = data.group_by {|x| x['sdk']}
    # Aggregate rows into x,y arrays and synth. objects for frontend.
    sdks = sdks.map do |sdk, value|
      rows = value.map { |x| {'month' => x['month'], 'install_base_count' => x['install_base_count']} }
      max_sort = value.map {|x| x['derivative_of_install_base_count']}.max
      rows.sort_by! {|x| x['month']}
      x = rows.map {|x| x['month'].iso8601.split("T")[0]}
      y = rows.map {|x| x['install_base_count']}
      sdk_obj = AndroidSdk.find_by_name(sdk)
      # Manipulate tags here, google requested we rename one
      # but holding off on that for the moment.
      if sdk_obj
        tags = sdk_obj.tags.map {|x| x.name}
      else
        tags = []
      end
      {'name' => sdk, 'sdk_website' => sdk_obj.try(:website), 'tags'=> tags,  'x' => x, 'y' => y, 'sort_by' => max_sort}
    end

    sdks.each do |sdk|
      # Rename firebase-database (Google request)
      if sdk['name'] == 'firebase-database'
        sdk['name'] = 'firebase-realtime-database'
      end
    end

    sdks[0..99]
  end

  # Don't run without refectoring to account for date window.
  def store_response
    MightyAws::S3.new.store(
      bucket: 'mightysignal-sdk-install-base-data',
      key_path: 'fastest_growing_sdk_report_2017.json.gz',
      data_str: {
        "absolute" => _transform(_fetch(false)),
        "relative" => _transform(_fetch(true))
      }.to_json
    )
  end
end
