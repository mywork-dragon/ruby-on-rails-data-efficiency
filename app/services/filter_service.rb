class FilterService
  class << self
  
    # @author Shane Wey
    def filter_companies(company_filters)
      company_results  = Company
      company_results = company_results.where("fortune_1000_rank <= ?", company_filters['fortuneRank'].to_i) if company_filters['fortuneRank']
      # company_results = company_results.where("funding >= ?", company_filters[:funding]) if company_filters[:funding]
      # company_results = company_results.where(country: company_filters[:country]) if company_filters[:country]
      company_results
    end
    
    # @author Shane Wey
    def company_ios_apps_query(company_filters)
      query = []
      
      if fortune_rank_s = company_filters['fortuneRank']
        fortune_rank = fortune_rank_s.to_i  #convert to i for safety
        query << "joins(ios_apps_websites: {website: :company}).where('companies.fortune_1000_rank <= ?', #{fortune_rank})"
      end
      
      query
    end
    
    # @author Jason Lew
    def company_android_apps_query(company_filters)
      query = []
      
      if fortune_rank_s = company_filters['fortuneRank']
        fortune_rank = fortune_rank_s.to_i  #convert to i for safety
        query << "joins(android_apps_websites: {website: :company}).where('companies.fortune_1000_rank <= ?', #{fortune_rank})"
      end
      
      query
    end

    def order_helper(apps_index, sort_by, order_by)
      if ['user_base', 'mobile_priority'].include?(sort_by)
        mapping = sort_by == 'user_base' ? IosApp.user_bases : IosApp.mobile_priorities
        apps_index.order(
                          {
                            "_script" => {
                              "script" => "doc['#{sort_by}'].empty ? -1 : factor[doc['#{sort_by}'].value]",
                              "params" => {
                                "factor" => mapping
                              },
                              "type" => "number",
                              "order" => order_by
                            }
                          }
                        )

      else
        apps_index.order(sort_by => order_by)
      end
    end

    def date_filter(filter)
      case filter["date"].to_i
      when 1
        {'gt' => 'now-7d/d'}
      when 2
        {'gte' => 'now-30d/d', 'lt' => 'now-7d/d'}
      when 3
        {'gte' => 'now-90d/d', 'lt' => 'now-30d/d'}
      when 4
       {'gte' => 'now-180d/d', 'lt' => 'now-90d/d'}
      when 5
        {'gte' => 'now-240d/d', 'lt' => 'now-180d/d'}
      when 6
        {'gte' => 'now-365d/d', 'lt' => 'now-240d/d'}
      when 7
        {'lt' => 'now-365d/d'}
      end
    end

    def filter_ios_apps(app_filters: nil, company_filters: nil, page_size: 50, page_num: 1, sort_by: 'name', order_by: 'asc')
      filter_apps(app_filters: app_filters, company_filters: company_filters, page_size: page_size, page_num: page_num, sort_by: sort_by, order_by: order_by, platform: 'ios')
    end

    def filter_android_apps(app_filters: nil, company_filters: nil, page_size: 50, page_num: 1, sort_by: 'name', order_by: 'asc')
      filter_apps(app_filters: app_filters, company_filters: company_filters, page_size: page_size, page_num: page_num, sort_by: sort_by, order_by: order_by, platform: 'android')
    end

    def filter_apps(app_filters: nil, company_filters: nil, page_size: 50, page_num: 1, sort_by: 'name', order_by: 'asc', platform: 'ios')
      apps_index = platform == 'ios' ? AppsIndex::IosApp : AppsIndex::AndroidApp

      ['sdkFiltersOr', 'sdkFiltersAnd'].each do |filter_type|
        next unless app_filters[filter_type].present?

        short_filter_type = filter_type == 'sdkFiltersOr' ? 'or' : 'and'
        sdk_query = {short_filter_type => []}
        app_filters[filter_type].each do |filter|
          date = date_filter(filter)
          case filter["status"].to_i
          when 0
            if date 
              sdk_query[short_filter_type] << {"nested" => {"path" => "installed_sdks", "filter" => {"and" => [{"terms" => {"installed_sdks.id" => [filter["id"]]}}, {"range" => {"installed_sdks.first_seen_date" => {'format' => 'date_time'}.merge(date)}} ]}}}
            else
              sdk_query[short_filter_type] << {"terms" => {"installed_sdks.id" => [filter["id"]]}}
            end
          when 1
            if date
              sdk_query[short_filter_type] << {"nested" => {"path" => "uninstalled_sdks", "filter" => {"and" => [{"terms" => {"uninstalled_sdks.id" => [filter["id"]]}}, {"range" => {"uninstalled_sdks.last_seen_date" => {'format' => 'date_time'}.merge(date)}} ]}}}
            else
              sdk_query[short_filter_type] << {"terms" => {"uninstalled_sdks.id" => [filter["id"]]}}
            end
          when 2
            sdk_query[short_filter_type] << {"and" => [{"not" => {"terms" => {"installed_sdks.id" => [filter["id"]]}}}, {"not" => {"terms" => {"uninstalled_sdks.id" => [filter["id"]]}}}]}
          when 3
            sdk_query[short_filter_type] << {"not" => {"terms" => {"installed_sdks.id" => [filter["id"]]}}}
          end
        end
        apps_index = apps_index.filter(sdk_query) unless sdk_query[short_filter_type].blank?
      end
      
      if company_filters['fortuneRank'].present?
        apps_index = apps_index.filter({"terms" => {"fortune_rank" => eval("[*'1'..'#{company_filters['fortuneRank'].to_i}']")}})
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

      if app_filters['mobilePriority'].present?
        apps_index = apps_index.filter({"terms" => {"mobile_priority" => app_filters['mobilePriority'], "execution" => "or"}})
      end

      if app_filters['userBases'].present?
        apps_index = apps_index.filter({"terms" => {"user_base" => app_filters['userBases'], "execution" => "or"}})
      end

      if app_filters['categories'].present?
        if platform == 'android'
          gaming_categories = [
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
          family_categories = [
           'Action & Adventure',
           'Brain Games',
           'Creativity',
           'Education',
           'Music & Video',
           'Pretend Play'
          ]
          app_filters['categories'] += gaming_categories if app_filters['categories'].include?('Games')
          app_filters['categories'] += family_categories if app_filters['categories'].include?('Family')
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
        
        download_ids = app_filters['downloads'].map{|x| x['id'].to_i}

        filter_values_array = []

        download_ids.each do |id|
          filter_values_array += download_min_values[id]
        end

        apps_index = apps_index.filter({"terms" => {"downloads_min" => filter_values_array, "execution" => "or"}})
      end

      apps_index = order_helper(apps_index, sort_by, order_by)

      apps_index = apps_index.limit(page_size).offset((page_num - 1) * page_size)
    end

    def ios_sort_order_query(sort_by, order_by)
      case sort_by
      when 'appName'
        return "where(\'ios_app_snapshots.name is not null\').order(\'ios_app_snapshots.name #{order_by}\')"
      when 'fortuneRank'
        return "where(\'companies.fortune_1000_rank is not null\').order(\'companies.fortune_1000_rank #{order_by}\')"
      when 'lastUpdated'
        return "where(\'ios_app_snapshots.released is not null\').order(\'ios_app_snapshots.released #{order_by}\')"
      when 'companyName'
        return "where(\'companies.name is not null\').order(\'companies.name #{order_by}\')"
      when 'developerName'
        return "where(\'ios_developers.name is not null\').order(\'ios_developers.name #{order_by}\')"
      when 'mobilePriority'
        return "where(\'ios_apps.mobile_priority is not null\').order(\'ios_apps.mobile_priority #{order_by}\')"
      when 'oldAdSpend'
        return "order(\'ios_fb_ad_appearances.ios_app_id #{order_by}\')"
      when 'adSpend'
        return "order(\'ios_fb_ads.ios_app_id #{order_by}\')"
      when 'userBases'
        return "where(\'ios_apps.user_base is not null\').order(\'ios_apps.user_base #{order_by}\')"
      when 'categories'
        return "where(\'ios_app_categories.name is not null\').order(\'ios_app_categories.name #{order_by}\')"
      end
    end

    def android_sort_order_query(sort_by, order_by)
      case sort_by
      when 'appName'
        return "where(\'android_app_snapshots.name is not null\').order(\'android_app_snapshots.name #{order_by}\')"
      when 'fortuneRank'
        return "where(\'companies.fortune_1000_rank is not null\').order(\'companies.fortune_1000_rank #{order_by}\')"
      when 'lastUpdated'
        return "where(\'android_app_snapshots.released is not null\').order(\'android_app_snapshots.released #{order_by}\')"
      when 'companyName'
        return "where(\'companies.name is not null\').order(\'companies.name #{order_by}\')"
      when 'developerName'
        return "where(\'android_developers.name is not null\').order(\'android_developers.name #{order_by}\')"
      when 'mobilePriority'
        return "where(\'android_apps.mobile_priority is not null\').order(\'android_apps.mobile_priority #{order_by}\')"
      when 'adSpend'
        return "order(\'android_fb_ad_appearances.android_app_id #{order_by}\')"
      when 'userBases'
        return "where(\'android_apps.user_base is not null\').order(\'android_apps.user_base #{order_by}\')"
      when 'downloads'
        return "where(\'android_app_snapshots.downloads_min is not null\').order(\'android_app_snapshots.downloads_min #{order_by}\')"
      when 'categories'
        return "where(\'android_app_categories.name is not null\').order(\'android_app_categories.name #{order_by}\')"
      end
    end

    def ios_apps_with_keywords(keywords)
      name_query_array = keywords.map{|k| "ios_app_snapshots.name LIKE \'%#{k}%\'"}
      name_query_string = name_query_array.join(' OR ')
      IosApp.includes(:ios_fb_ad_appearances, newest_ios_app_snapshot: :ios_app_categories, websites: :company).joins(:newest_ios_app_snapshot).where(name_query_string)
    end
    
    def android_apps_with_keywords(keywords)
      name_query_array = keywords.map{|k| "android_app_snapshots.name LIKE \'%#{k}%\'"}
      name_query_string = name_query_array.join(' OR ')
      IosApp.includes(:android_fb_ad_appearances, newest_android_app_snapshot: :android_app_categories, websites: :company).joins(:newest_android_app_snapshot).where(name_query_string)
    end
    
    def companies_with_keywords(keywords)
      name_query_array = keywords.map{|k| "name LIKE \'%#{k}%\'"}
      name_query_string = name_query_array.join(' OR ')
      Company.where(name_query_string)
    end
    
    def ios_apps_of_companies(companies)
      if companies.present?
        return IosApp.includes(:ios_fb_ad_appearances, newest_ios_app_snapshot: :ios_app_categories, websites: :company).joins(ios_apps_websites: {website: :company}).where("companies.id IN (#{companies.pluck(:id).join(',')})")
      else
        return IosApp.where(id: nil).where('id IS NOT ?', nil)
      end
    end
    
    def android_apps_of_companies(companies)
      if companies.present?
        return AndroidApp.includes(:android_fb_ad_appearances, newest_android_app_snapshot: :android_app_categories, websites: :company).joins(android_apps_websites: {website: :company}).where("companies.id IN (#{companies.pluck(:id).join(',')})")
      else
        return AndroidApp.where(id: nil).where('id IS NOT ?', nil)
      end
    end
    
    def ios_apps_of_snapshots(snapshots)
      app_ids = snapshots.pluck(:ios_app_id)
      IosApp.where(id: app_ids)
    end
    
    def ios_app_union(relation1, relation2)
      app_ids = relation1.pluck(:id) + relation2.pluck(:id)
      IosApp.where(id: app_ids.uniq)
    end
  end
end