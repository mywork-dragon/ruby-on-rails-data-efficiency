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
         GROUP BY sdk
         ORDER BY max(derivative_of_install_base_count #{relative_clause}) DESC LIMIT 100)
      AND sdk_install_bases.month <= dateadd('month', -2, getdate())
      ORDER BY month;
    "
    RedshiftDbConnection.new.query(sql).fetch
  end

  def _transform(data)
    sdks = data.group_by {|x| x['sdk']}
    sdks = sdks.map do |sdk, value|
      rows = value.map { |x| {'month' => x['month'], 'install_base_count' => x['install_base_count']} }
      max_sort = value.map {|x| x['derivative_of_install_base_count']}.max
      rows.sort_by! {|x| x['month']}
      x = rows.map {|x| x['month'].iso8601.split("T")[0]}
      y = rows.map {|x| x['install_base_count']}
      sdk_obj = AndroidSdk.find_by_name(sdk)
      {'name' => sdk, 'sdk_website' => sdk_obj.website, 'tags'=> sdk_obj.tags.map {|x| x.name},  'x' => x, 'y' => y, 'sort_by' => max_sort}
    end
    sdks
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
