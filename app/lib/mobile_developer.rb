module MobileDeveloper
  def get_website_urls
    websites.pluck(:url).uniq
  end

  def get_valid_website_urls
    valid_websites.pluck(:url).uniq
  end

  def fortune_1000_rank
    valid_websites.joins(:domain_datum).pluck(:fortune_1000_rank).compact.min
  end

  def is_major_publisher?
    tags.any? { |tag| tag.name == "Major Publisher" }
  end

  def headquarters(limit=100)
    headquarters = []
    valid_websites.joins(:domain_datum).uniq.limit(limit).
      pluck('domain_data.domain','street_number','street_name','sub_premise','city','postal_code','state',
            'state_code','country','country_code','lat','lng').each do |data|
      next unless data[9]
      headquarters << {
        domain: data[0],
        street_number: data[1],
        street_name: data[2],
        sub_premise: data[3],
        city: data[4],
        postal_code: data[5],
        state: data[6],
        state_code: data[7],
        country: data[8],
        country_code: data[9],
        lat: data[10],
        lng: data[11]
      }
    end
    headquarters.uniq
  end

  def sorted_apps(category, order, page)
    filter_args = {
      app_filters: {'publisherId' => self.id},
      page_size: 100,
      page_num: [page.to_i, 1].max,
      sort_by: category || 'last_updated',
      order_by: order || 'desc'
    }

    if platform == :ios
      filter_results = FilterService.filter_ios_apps(filter_args)
      app_class = IosApp
    else
      filter_results = FilterService.filter_android_apps(filter_args)
      app_class = AndroidApp
    end

    ids = filter_results.map { |result| result.attributes["id"] }
    results = ids.any? ? app_class.where(id: ids).order("FIELD(id, #{ids.join(',')})") : []
    return results, filter_results.total_count
  end

  def link(stage: :production, utm_source: nil)
    developer_link = if stage == :production
      "https://mightysignal.com/app/app#/publisher/#{platform}/#{id}"
    elsif stage == :staging
      "https://staging.mightysignal.com/app/app#/publisher/#{platform}/#{id}"
    end
    developer_link += "?utm_source=#{utm_source}" if utm_source
    developer_link
  end

  def tagged_sdk_summary
    app_index = (platform == :ios ? AppsIndex::IosApp : AppsIndex::AndroidApp)
    sdk_class = (platform == :ios ? IosSdk : AndroidSdk)

    summary = {}

    [:installed_sdks, :uninstalled_sdks].each do |sdk_type|
      summary[sdk_type] = Hash.new([])
      sdks = app_index.filter({"term" => {"publisher_id" => id}}).aggs({ top_sdks: {terms: { field: "#{sdk_type}.id", size: 1000 } }}).aggs["top_sdks"]["buckets"]
      sdks.each do |sdk|
        app_sdk = sdk_class.find(sdk["key"])
        tag_name = app_sdk.tags.first.try(:name) || 'Others'
        summary[sdk_type][tag_name] += [{id: app_sdk.id, name: app_sdk.name, favicon: app_sdk.favicon, count: sdk["doc_count"]}]
      end
    end

    summary
  end
end
