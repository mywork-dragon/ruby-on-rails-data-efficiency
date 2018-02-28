module MobileDeveloper

  def apps
    ios? ? ios_apps : android_apps
  end

  def get_website_urls
    websites.pluck(:url).uniq
  end

  def get_valid_website_urls
    valid_websites.pluck(:url).uniq
  end

  def fortune_1000_rank
    domains = DomainLinker.new.publisher_to_domains(self.platform, self.id)
    DomainDatum.where(:domain => domains).pluck(:fortune_1000_rank).compact.min
  end

  def is_major_publisher?
    tags.any? { |tag| tag.name == "Major Publisher" }
  end

  def tag_as_major_publisher
    major_tag = Tag.find_by(name: "Major Publisher")
    TagRelationship.find_or_create_by(tag_id: major_tag.id, taggable_id: self.id, taggable_type: self.class.name)
    apps = self.class.name == "IosDeveloper" ? self.ios_apps : self.android_apps
    apps.each { |app| app.tag_as_major_app }
  end

  def untag_as_major_publisher
    major_tag = Tag.find_by(name: "Major Publisher")
    tag = TagRelationship.find_by(tag_id: major_tag.id, taggable_id: self.id, taggable_type: self.class.name)
    tag.destroy
    apps = self.class.name == "IosDeveloper" ? self.ios_apps : self.android_apps
    apps.each { |app| app.untag_as_major_app }
  end

  def linkedin_handle
    valid_websites.joins(:domain_datum).pluck(:linkedin_handle).uniq.compact.first
  end

  def crunchbase_handle
    valid_websites.joins(:domain_datum).pluck(:crunchbase_handle).uniq.compact.first
  end

  def company_size
    valid_websites.joins(:domain_datum).pluck(:employees_range).uniq.compact.first
  end

  def logo_url
    valid_websites.joins(:domain_datum).pluck(:logo_url).uniq.compact.first
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
      page_size: 25,
      page_num: [page.to_i, 1].max,
      sort_by: category || 'last_updated',
      order_by: order || 'desc'
    }

    if ios?
      filter_results = FilterService.filter_ios_apps(filter_args)
      app_class = IosApp
    else
      filter_results = FilterService.filter_android_apps(filter_args)
      app_class = AndroidApp
    end

    ids = filter_results.map { |result| result.attributes["id"] }
    results = ids.any? ? app_class.where(id: ids).order("FIELD(id, #{ids.join(',')})") : []
    return results
  end

  def num_apps
    filter_args = {
      app_filters: { 'publisherId' => self.id }
    }

    if ios?
      results = FilterService.filter_ios_apps(filter_args)
    else
      results = FilterService.filter_android_apps(filter_args)
    end
    results.total_count
  end

  def ios?
    platform == :ios
  end

  def android?
    platform == :android
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
    app_index = (ios? ? AppsIndex::IosApp : AppsIndex::AndroidApp)
    sdk_class = (ios? ? IosSdk : AndroidSdk)

    summary = {}

    [:installed_sdks, :uninstalled_sdks].each do |sdk_type|
      summary[sdk_type] = Hash.new([])
      sdks = app_index.filter({"term" => {"publisher_id" => id}}).aggs({ top_sdks: {terms: { field: "#{sdk_type}.id", size: 1000 } }}).aggs["top_sdks"]["buckets"]
      sdks.each do |sdk|
        app_sdk = sdk_class.find(sdk["key"])
        tag_name = app_sdk.tags.first.try(:name) || 'Others'
        summary[sdk_type][tag_name] += [{id: app_sdk.id, name: app_sdk.name, favicon: app_sdk.favicon, count: sdk["doc_count"]}]
      end
      summary[sdk_type] = summary[sdk_type].sort.to_h      
    end

    summary
  end
end
