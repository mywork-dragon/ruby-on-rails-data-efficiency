class FilterService
  class << self

    def order_helper(apps_index, sort_by, order_by)
      if sort_by == 'mobile_priority'
        mapping = IosApp.mobile_priorities
        apps_index.order(
                          {
                            "_script" => {
                              "script" => "doc['#{sort_by}'].empty ? 3 : factor[doc['#{sort_by}'].value]",
                              "params" => {
                                "factor" => mapping
                              },
                              "type" => "number",
                              "order" => order_by
                            }
                          }
                        )

      elsif sort_by == 'name'
        apps_index.order('name.lowercase' => {'order' => order_by, "missing" => "_last"})
      elsif sort_by == 'publisher_name'
        apps_index.order('publisher_name.lowercase' => {'order' => order_by, "missing" => "_last"})
      else
        apps_index.order(sort_by => {'order' => order_by, "missing" => "_last"})
      end
    end

    def date_filter(filter)
      case filter["date"].to_i
        when 1
          {'gte' => 'now-7d/d'}
        when 2
          {'gte' => 'now-1M/d'}
        when 3
          {'gte' => 'now-3M/d'}
        when 4
          {'gte' => 'now-6M/d'}
        when 5
          {'gte' => 'now-9M/d'}
        when 6
          {'gte' => 'now-1y/d'}
        when 7
          {'gte' => filter["dateRange"]["from"].to_datetime, 'lte' => filter["dateRange"]["until"].to_datetime}
        # old date ranges
        when 8
          {'gte' => 'now-30d/d', 'lt' => 'now-7d/d'}
        when 9
          {'gte' => 'now-90d/d', 'lt' => 'now-30d/d'}
        when 10
          {'gte' => 'now-180d/d', 'lt' => 'now-90d/d'}
        when 11
          {'gte' => 'now-240d/d', 'lt' => 'now-180d/d'}
        when 12
          {'gte' => 'now-365d/d', 'lt' => 'now-240d/d'}
      end
    end

    def engagement_filter(filter)
      range = filter["id"].split('-').last(2)
      range.map!{|num|
        case num.to_i
        when 0
          0
        when 1
          10_000
        when 2
          50_000
        when 3
          100_000
        when 4
          500_000
        when 5
          1_000_000
        when 6
          5_000_000
        when 7
          10_000_000
        when 8
          200_000_000
        end
      }

      {'gte' => range[0], 'lte' => range[1]}
    end

    def filter_ios_apps(app_filters: {}, company_filters: {}, page_size: 50, page_num: 1, sort_by: 'name', order_by: 'asc')
      filter_apps(app_filters: app_filters, company_filters: company_filters, page_size: page_size, page_num: page_num, sort_by: sort_by, order_by: order_by, platform: 'ios')
    end

    def filter_android_apps(app_filters: {}, company_filters: {}, page_size: 50, page_num: 1, sort_by: 'name', order_by: 'asc')
      filter_apps(app_filters: app_filters, company_filters: company_filters, page_size: page_size, page_num: page_num, sort_by: sort_by, order_by: order_by, platform: 'android')
    end

    def filter_apps(app_filters: {}, company_filters: {}, page_size: 50, page_num: 1, sort_by: 'name', order_by: 'asc', platform: 'ios')
      apps_index = platform == 'ios' ? AppsIndex::IosApp : AppsIndex::AndroidApp

      ['sdkFiltersOr', 'sdkFiltersAnd', 'sdkCategoryFiltersOr', 'sdkCategoryFiltersAnd'].each do |filter_type|
        next unless app_filters[filter_type].present?

        short_filter_type = ['sdkFiltersOr', 'sdkCategoryFiltersOr'].include?(filter_type) ? 'or' : 'and'
        sdk_query = { short_filter_type => [] }

        app_filters[filter_type].each do |filter|
          if !filter['selectedSdks'].nil?
            if filter['selectedSdks'] == 'all'
              category = Tag.find(filter['id'])
              sdk_ids = platform == 'ios' ? category.ios_sdks.pluck(:id) : category.android_sdks.pluck(:id)
            else
              sdk_ids = filter['selectedSdks']
            end
          else
            sdk_ids = [filter['id']]
          end

          date = date_filter(filter)
          case filter["status"].to_i
          when 0
            if date
              sdk_query[short_filter_type] << {"nested" => {"path" => "installed_sdks", "filter" => {"and" => [{"terms" => {"installed_sdks.id" => sdk_ids}}, {"range" => {"installed_sdks.first_seen_date" => {'format' => 'date_time'}.merge(date)}} ]}}}
            else
              sdk_query[short_filter_type] << {"terms" => {"installed_sdks.id" => sdk_ids}}
            end
          when 1
            if date
              sdk_query[short_filter_type] << {"nested" => {"path" => "uninstalled_sdks", "filter" => {"and" => [{"terms" => {"uninstalled_sdks.id" => sdk_ids}}, {"range" => {"uninstalled_sdks.first_unseen_date" => {'format' => 'date_time'}.merge(date)}} ]}}}
            else
              sdk_query[short_filter_type] << {"terms" => {"uninstalled_sdks.id" => sdk_ids}}
            end
          when 2
            sdk_query[short_filter_type] << {"and" => [{"not" => {"terms" => {"installed_sdks.id" => sdk_ids}}}, {"not" => {"terms" => {"uninstalled_sdks.id" => sdk_ids}}}]}
          when 3
            sdk_query[short_filter_type] << {"not" => {"terms" => {"installed_sdks.id" => sdk_ids}}}
          end
        end
        apps_index = apps_index.filter(sdk_query) unless sdk_query[short_filter_type].blank?
      end

      ['locationFiltersOr', 'locationFiltersAnd'].each do |filter_type|
        next unless app_filters[filter_type].present?

        short_filter_type = filter_type == 'locationFiltersOr' ? 'or' : 'and'
        location_query = {short_filter_type => []}
        app_filters[filter_type].each do |filter|
          case filter["status"].to_i
          when 0
            if filter["state"].present? && filter['state'] != "0"
              location_query[short_filter_type] << {"nested" => {"path" => "headquarters", "filter" => {"and" => [{"terms" => {"headquarters.country_code" => [filter["id"]]}}, {"terms" => {"headquarters.state_code" => [filter["state"]]}}]}}}
            else
              location_query[short_filter_type] << {"term" => {"headquarters.country_code" => filter["id"]}}
            end
          when 1
            location_query[short_filter_type] << {"and" => [{"term" => {"app_stores.country_code" => filter["id"]}}, {"term" => {"app_stores_count" => 1}}]}
          when 2
            location_query[short_filter_type] << {"term" => {"app_stores.country_code" => filter["id"]}}
          when 3
            location_query[short_filter_type] << {"not" => {"term" => {"app_stores.country_code" => filter["id"]}}}
          end
        end
        apps_index = apps_index.filter(location_query) unless location_query[short_filter_type].blank?
      end

      ['userbaseFiltersOr', 'userbaseFiltersAnd'].each do |filter_type|
        next unless app_filters[filter_type].present?

        short_filter_type = filter_type == 'userbaseFiltersOr' ? 'or' : 'and'
        userbase_query = {short_filter_type => []}
        app_filters[filter_type].each do |filter|
          engagement_filter = engagement_filter(filter) if filter["status"].to_i != 0
          case filter["status"].to_i
          when 0
            userbase_query[short_filter_type] << {"term" => {"user_bases.user_base" => IosApp.user_bases.keys[filter['id'].to_f - 1]}}
          when 1
            userbase_query[short_filter_type] << {"range" => {"daily_active_users_num" => engagement_filter}}
          when 2
            userbase_query[short_filter_type] << {"range" => {"weekly_active_users_num" => engagement_filter}}
          when 3
            userbase_query[short_filter_type] << {"range" => {"monthly_active_users_num" => engagement_filter}}
          end
        end
        apps_index = apps_index.filter(userbase_query) unless userbase_query[short_filter_type].blank?
      end

      if company_filters['fortuneRank'].present?
        apps_index = apps_index.filter({"terms" => {"fortune_rank" => eval("[*'1'..'#{company_filters['fortuneRank'].to_i}']")}})
      end

      if app_filters['appIds'].present?
        apps_index = apps_index.query({"ids" => {"values" => app_filters['appIds'].map(&:to_s)}})
      end

      if app_filters['adSpend'].present?
        apps_index = apps_index.filter({"terms" => {"facebook_ads" => [true]}})
      end

      if app_filters['price'].present?
        apps_index = app_filters['price'] == 'paid' ? apps_index.filter({"terms" => {"paid" => [true]}}) : apps_index.filter({"not" => {"terms" => {"paid" => [true]}}})
      end

      if app_filters['inAppPurchases'].present?
        apps_index = app_filters['inAppPurchases'] == 'true' ? apps_index.filter({"terms" => {"in_app_purchases" => [true]}}) : apps_index.filter({"not" => {"terms" => {"in_app_purchases" => [true]}}})
      end

      if app_filters['oldAdSpend'].present?
        apps_index = apps_index.filter({"terms" => {"old_facebook_ads" => [true]}})
      end

      if app_filters['publisherId'].present?
        apps_index = apps_index.filter({"term" => {"publisher_id" => app_filters['publisherId']}})
      end

      if app_filters['mobilePriority'].present?
        apps_index = apps_index.filter({"terms" => {"mobile_priority" => app_filters['mobilePriority'], "execution" => "or"}})
      end

      if app_filters['userBases'].present?
        if platform == 'ios'
          apps_index = apps_index.filter({"terms" => {"user_bases.user_base" => app_filters['userBases'], "execution" => "or"}})
        else
          apps_index = apps_index.filter({"terms" => {"user_base" => app_filters['userBases'], "execution" => "or"}})
        end
      end

      if app_filters['categories'].present?
        if platform == 'android'
          app_filters['categories'] += android_gaming_categories if app_filters['categories'].include?('Games')
          app_filters['categories'] += android_family_categories if app_filters['categories'].include?('Family')
        end
        apps_index = apps_index.filter({"terms" => {"categories" => app_filters['categories'], "execution" => "or"}})
      end

      if app_filters['downloads'] #android only

        # Download Value Ranges - broken up to intervals of scraped data
        download_min_values = [
            [1, 5, 10, 50, 100, 500, 1000, 5000, 10000],  # 0 - 50K
            [50000, 100000],                              # 50K - 500K
            [500000, 1000000, 5000000],                   # 500K - 10M
            [10000000, 50000000],                         # 10M - 100M
            [100000000, 500000000],                       # 100M - 1B
            [1000000000]                                  # 1B - 5B
        ]

        download_ids = app_filters['downloads']

        filter_values_array = []

        download_ids.each do |id|
          filter_values_array += download_min_values[id]
        end

        apps_index = apps_index.filter({"terms" => {"downloads_min" => filter_values_array, "execution" => "or"}})
      end

      apps_index = order_helper(apps_index, sort_by, order_by)
      apps_index = apps_index.limit(page_size).offset((page_num - 1) * page_size)
    end

    def filter_ad_spend_apps (page_size: 20, page_num: 1, sort_by: 'first_seen_ads', order_by: 'desc')
      ad_spend_apps = AppsIndex.filter({"terms" => {"facebook_ads" => [true]}})
      ordered_ad_spend_apps = order_helper(ad_spend_apps, sort_by, order_by)
      ordered_ad_spend_apps.limit(page_size).offset((page_num - 1) * page_size)
    end

    def android_gaming_categories
      [
       'Action',
       'Adventure',
       'Arcade',
       'Board',
       'Card',
       'Casino',
       'Casual',
       'Educational',
       'Music',
       'Puzzle',
       'Racing',
       'Role Playing',
       'Simulation',
       'Sports',
       'Strategy',
       'Trivia',
       'Word'
      ]
    end

    def android_family_categories
      [
       'Action & Adventure',
       'Brain Games',
       'Creativity',
       'Education',
       'Music & Video',
       'Pretend Play'
      ]
    end
  end
end
