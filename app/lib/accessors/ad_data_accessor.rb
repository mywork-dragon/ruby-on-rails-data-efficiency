class AdDataAccessor
  MAX_PAGE_SIZE = 100

  def initialize
    @delegate = RedshiftAdDataAccessor.new
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
    page_size = [page_size.to_i, MAX_PAGE_SIZE].min
    page_number = [page_number.to_i, 0].max
    if source_ids.nil?
      source_ids = account.available_ad_sources.values.map {|x| x[:id]}
    end
    source_ids = account.restrict_ad_sources(source_ids)
    platforms = platforms.select {|x| AdDataPermissions::APP_PLATFORMS.include? x}

    @delegate.query(
      platforms:platforms,
      source_ids: source_ids,
      sort_by: sort_by,
      order_by: order_by,
      page_size: page_size,
      page_number:page_number
      )
  end
end
