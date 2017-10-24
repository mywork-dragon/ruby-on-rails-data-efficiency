class AdDataAccessor
  MAX_PAGE_SIZE = 100

  def available_sources(account)
    # Returns a list of ad intel data sources (networks).
    # Returns:
    #   [{id:'facebook', name:'Facebook', icon: 'https://www.google.com/s2/favicons?domain=facebook.com', 'can_access': true},...]
    return [
        {
          id:'facebook',
          name:'Facebook',
          icon: 'https://www.google.com/s2/favicons?domain=facebook.com',
          can_access: true
        },
        {
          id:'chartboost',
          name:'ChartBoost',
          icon: 'https://www.google.com/s2/favicons?domain=chartboost.com',
          can_access: false
        },
        {
          id:'applovin',
          name:'Applovin',
          icon: 'https://www.google.com/s2/favicons?domain=applovin.com',
          can_access: false
        }
      ]
  end

  def restrict_sources(account, source_ids)
    enabled_sources = available_sources(account).select{|x| x[:can_access]}.map {|x| x[:id]}
    source_ids.select {|source_id| enabled_sources.include? source_id}
  end

  def query(
    account,
    platforms:['ios', 'android'],
    source_ids: nil,
    sort_by: 'first_seen_ads_date',
    order_by: 'desc',
    page_size: 20,
    page_number:0)
    # Filters and sorts apps by ad intel data.
    # Params:
    #   account: The account with which to scope the query by (some accounts can access a subset of data).
    #   platforms: The platforms to filter this query by.
    #   sort_by: A field to sort the result set by one of first_seen_ads_date, last_seen_ads_date or user_base_display_score.
    #   order_by: Order by asc or desc,
    #   source_ids: A list of source_ids from available_sources to which this query applies to nil => all supported.
    # Returns:
    # [
    #     {
    #         "id": 215,
    #         "platform": "android",
    #         "categories": [
    #             {
    #                 "name": "Weather",
    #                 "id": "WEATHER"
    #             }
    #         ],
    #         "user_base_display_score": 0,
    #         "user_base_name": "elite",
    #         "icon": "//lh3.googleusercontent.com/nIenkMvx3o8AcWeqoT9BQwBNLAxSy_DwmcdgUCMx4K9P65aqhzpQHJbmVDHsvUIqkmM=w300",
    #         "publisher": {
    #             "name": "MACHAPP Software Ltd",
    #             "id": 243
    #         },
    #         "first_seen_ads_date": "2017-09-11T19:49:51.000-07:00",
    #         "first_seen_ads_days": 42,
    #         "last_seen_ads_date": "2017-09-11T21:26:32.000-07:00",
    #         "last_seen_ads_days": 42,
    #         "ad_attribution_sdks": [],
    #         "ad_sources" : ['facebook']
    #     },
    #     {
    #         "id": 3310094,
    #         "platform": "ios",
    #         "categories": [
    #             {
    #                 "name": "Games",
    #                 "type": "primary",
    #                 "id": "Games"
    #             }
    #             ...
    #         ],
    #         "user_base_display_score": 33,
    #         "user_base_name": "weak",
    #         "user_bases": [
    #             {
    #                 "country_code": "US",
    #                 "user_base": "weak",
    #                 "country": "United States",
    #                 "score": 33
    #             },
    #             ...
    #         ],
    #         "icon": "https://is4-ssl.mzstatic.com/image/thumb/Purple127/v4/cd/b9/d5/cdb9d599-ae5f-5e32-c344-69c640fdc448/source/100x100bb.jpg",
    #         "publisher": {
    #             "name": "Waranthorn Chaikhamruang",
    #             "id": 516072
    #         },
    #         "first_seen_ads_date": "2017-10-23T08:09:22.000-07:00",
    #         "first_seen_ads_days": 0,
    #         "last_seen_ads_date": "2017-10-23T08:09:22.000-07:00",
    #         "last_seen_ads_days": 0,
    #         "ad_attribution_sdks": [],
    #         "ad_sources" : ['facebook']
    #     },
    # ]
    page_size = [page_size, MAX_PAGE_SIZE].min
    page_number = [page_number, 0].max
    if source_ids.nil?
      source_ids = available_sources(account).map {|x| x[:id]}
    end
    source_ids = restrict_sources(account, source_ids)


    results = []
    if source_ids.include? 'facebook'
      if platforms.include? 'android'
        android_apps = AndroidApp.joins(:android_ads).group('android_apps.id').limit(page_size).offset(page_number*page_size)
        android_apps.each do |app|
          results.append({
              'id' => app.id,
              'name' => app.name,
              'platform' => app.platform,
              'app_available' => app.app_available?,
              'categories' => app.android_app_snapshot_categories.map{|x| x.as_json},
              'user_base_display_score' => app.user_base_display_score,
              'user_base_name' => app.user_base,
              'icon' => app.icon_url,
              'publisher' =>  app.android_developer.as_json.slice('name', 'id'),
              'first_seen_ads_date' => app.first_seen_ads_date,
              'first_seen_ads_days' => app.first_seen_ads_days,
              'last_seen_ads_date' => app.last_seen_ads_date,
              'last_seen_ads_days' => app.last_seen_ads_days,
              'ad_attribution_sdks' => app.ad_attribution_sdks,
              'ad_formats' => [{'id' => 'facebook_news_feed', 'name' => 'Facebook News Feed'}],
              'ad_sources' => [{'id' => 'facebook'}]
            })
        end
      end
      if platforms.include? 'ios'
        snapaccessor = IosSnapshotAccessor.new
        filter_results = FilterService.filter_ios_ad_spend_apps(page_size: page_size, page_num: page_number + 1)
        ios_apps = filter_results.map { |result| IosApp.find(result.attributes['id']) }
        ios_apps.each do |app|
          results.append({
              'id' => app.id,
              'name' => app.name,
              'platform' => app.platform,
              'app_available' => app.app_store_available,
              'categories' => snapaccessor.categories_from_ios_app(app).map {|x| {'name' => x['name'], 'type' => x['type'], 'id' => x['name']}},
              'user_base_display_score' => app.user_base_display_score,
              'user_base_name' => app.user_base,
              'user_bases' => app.scored_user_bases,
              'icon' => app.icon_url,
              'publisher' =>  app.ios_developer.as_json.slice('name', 'id'),
              'first_seen_ads_date' => app.first_seen_ads_date,
              'first_seen_ads_days' => app.first_seen_ads_days,
              'last_seen_ads_date' => app.last_seen_ads_date,
              'last_seen_ads_days' => app.last_seen_ads_days,
              'ad_attribution_sdks' => app.ad_attribution_sdks,
              'ad_formats' => [{'id' => 'facebook_news_feed', 'name' => 'Facebook News Feed'}],
              'ad_sources' => [{'id' => 'facebook'}]
            })
        end
      end
    end
    results = results[0..page_size-1]
    if order_by == 'desc'
      results.sort_by {|x| x[sort_by]}.reverse
    else
      results.sort_by {|x| x[sort_by]}
    end
  end
end
