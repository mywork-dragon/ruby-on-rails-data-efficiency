class FilterService
  class << self
  
    def filter_companies(company_filters)
      company_results  = Company
      company_results = company_results.where("fortune_1000_rank <= ?", company_filters[:fortuneRank].to_i) if company_filters[:fortuneRank]
      # company_results = company_results.where("funding >= ?", company_filters[:funding]) if company_filters[:funding]
      # company_results = company_results.where(country: company_filters[:country]) if company_filters[:country]
      company_results
    end
    
    def company_apps_query(company_filters)
      query = []
      query << 'company_results.where("fortune_1000_rank <= ?", company_filters[:fortuneRank].to_i)' if company_filters[:fortuneRank]
      # company_results = company_results.where("funding >= ?", company_filters[:funding]) if company_filters[:funding]
      # company_results = company_results.where(country: company_filters[:country]) if company_filters[:country]
      return query
    end
    
    def apps_query(app_filters)
      limit = 10 #TODO: pass this as parameter later
      queries = []
      first_object = IosApp
      
      # queries << 'includes(:ios_fb_ad_appearances, newest_ios_app_snapshot: :ios_app_categories, websites: :company)'
      if app_filters[:mobilePriority]
        mobile_priorities = []
        mobile_priorities << IosApp.mobile_priorities[:high] if app_filters[:mobilePriority].include?("High")
        mobile_priorities << IosApp.mobile_priorities[:medium] if app_filters[:mobilePriority].include?("Medium")
        mobile_priorities << IosApp.mobile_priorities[:low] if app_filters[:mobilePriority].include?("Low")
        queries << "where(mobile_priority: #{mobile_priorities})"
      end
      
      queries << 'joins(:ios_fb_ad_appearances)' if app_filters[:adSpend]
      
      if app_filters[:userBases]
        user_bases = []
        user_bases << IosApp.user_bases[:elite] if app_filters[:userBases].include?("Elite")
        user_bases << IosApp.user_bases[:strong] if app_filters[:userBases].include?("Strong")
        user_bases << IosApp.user_bases[:moderate] if app_filters[:userBases].include?("Moderate")
        user_bases << IosApp.user_bases[:weak] if app_filters[:userBases].include?("Weak")
        queries << "where(user_base: #{user_bases})"
      end
      
      if app_filters[:updatedMonthsAgo]
        queries << "joins(:newest_ios_app_snapshot).where('released > ?', #{app_filters[:updatedMonthsAgo].to_i.months.ago.to_date})"
      end
      
      if app_filters[:categories]
        cats_with_quotes = app_filters[:categories].map{|c| "\'#{c}\'"}
        queries << "joins(newest_ios_app_snapshot: {ios_app_categories_snapshots: :ios_app_category}).where('ios_app_categories.name IN (?)', #{cats_with_quotes.join(',')})"
      end
      
      return queries
      # query = queries.join('.')
      # puts "Query: #{query}"
      # first_object.instance_eval("self.#{query}.limit(#{limit})")
    end
    
    def app_keywords_query(keywords)
      name_query_array = keywords.map{|k| "ios_app_snapshots.name LIKE \'%#{k}%\'"}
      query = "joins(:newest_ios_app_snapshot).where(#{name_query_array.join(' OR ')})"
      return query
      
    end
    
    # def sort_order_query(sort_by, order_by)
    #   query = nil
    #   case sort_by
    #   when 'appName'
    #
    #   when 'fortuneRank'
    #
    #   when ''
    #   end
    # end
    
    def apps_with_keywords(keywords)
      name_query_array = keywords.map{|k| "ios_app_snapshots.name LIKE \'%#{k}%\'"}
      name_query_string = name_query_array.join(' OR ')
      return IosApp.includes(:ios_fb_ad_appearances, newest_ios_app_snapshot: :ios_app_categories, websites: :company).joins(:newest_ios_app_snapshot).where(name_query_string)
    end
    
    def companies_with_keywords(keywords)
      name_query_array = keywords.map{|k| "name LIKE \'%#{k}%\'"}
      name_query_string = name_query_array.join(' OR ')
      return Company.where(name_query_string)
    end
    
    def apps_of_companies(companies)
      if companies.present?
        return IosApp.includes(:ios_fb_ad_appearances, newest_ios_app_snapshot: :ios_app_categories, websites: :company).joins(ios_apps_websites: {website: :company}).where("companies.id IN (#{companies.pluck(:id).join(',')})")
      else
        return IosApp.where(id: nil).where('id IS NOT ?', nil)
      end
    end
    
    def apps_of_snapshots(snapshots)
      app_ids = snapshots.pluck(:ios_app_id)
      return IosApp.where(id: app_ids)
    end
    
    def ios_app_union(relation1, relation2)
      app_ids = relation1.pluck(:id) + relation2.pluck(:id)
      IosApp.where(id: app_ids.uniq)
    end
  end
end