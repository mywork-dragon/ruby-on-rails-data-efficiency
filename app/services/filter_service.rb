class FilterService
  class << self
  
    def companies_above_fortune_rank(fortune_rank)
      Company.where("fortune_1000_rank <= #{fortune_rank}")
    end
  
    def companies_above_funding(funding)
      Company.where("funding >= #{funding}")
    end
    
    def companies_in_countries(countries)
      # Company.where("country IN (?)", countries.join(','))
      Company.where(country: countries)
    end
    
    def apps_with_user_bases(user_bases)
      puts "in apps with user bases"
      snapshot_results = []
      elite_floor_ratio = 7
      elite_floor_total = 10e3
      strong_floor_ratio = 1
      strong_floor_total = 10e3
      moderate_floor_ratio = 0.1
      moderate_floor_total = 100
      for user_base in user_bases
        if user_base == 'Elite'
          ratio_elite_snapshots = IosAppSnapshot.select(:id, :ios_app_id).where("ratings_per_day_current_release >= 7")
          total_elite_snapshots = IosAppSnapshot.select(:id, :ios_app_id).where("ratings_all_count >= 50000")
          all_elite_snapshots = (ratio_elite_snapshots + total_elite_snapshots).uniq
          snapshot_results.concat all_elite_snapshots
        elsif user_base == 'Strong' 
          ratio_strong_snapshots = IosAppSnapshot.select(:id, :ios_app_id).where("ratings_per_day_current_release < 7 AND ratings_per_day_current_release >= 1")
          total_elite_snapshots = IosAppSnapshot.select(:id, :ios_app_id).where("ratings_all_count < 50000 AND ratings_all_count >= 10000")
          all_strong_snapshots = (ratio_strong_snapshots + total_elite_snapshots).uniq
          snapshot_results.concat all_strong_snapshots
        elsif user_base == 'Moderate'
          ratio_moderate_snapshots = IosAppSnapshot.select(:id, :ios_app_id).where("ratings_per_day_current_release < 1 AND ratings_per_day_current_release >= 0.1")
          total_moderate_snapshots = IosAppSnapshot.select(:id, :ios_app_id).where("ratings_all_count < 10000 AND ratings_all_count >= 100")
          all_moderate_snapshots = (ratio_moderate_snapshots + total_moderate_snapshots).uniq
          snapshot_results.concat all_moderate_snapshots
        elsif user_base == 'Weak'
          puts "in weak user_base"
          ratio_weak_snapshots = IosAppSnapshot.where("ratings_per_day_current_release < 0.1")
          total_weak_snapshots = IosAppSnapshot.where("ratings_all_count < 100")
          all_weak_snapshots = (ratio_weak_snapshots + total_weak_snapshots).uniq
          snapshot_results.concat all_weak_snapshots
        end
      end
      snapshot_results.uniq!
      if snapshot_results.present?
        ios_app_ids = snapshot_results.map{|s| s.ios_app_id}
        # return IosApp.where("id IN (#{ios_app_ids.join(',')})")
        return IosApp.where(id: ios_app_ids)
      else
        return IosApp.where("id=-1") #have to return Relation object, even if it is blank
      end
    end
  
    def apps_updated_months_ago(months_ago)
      ios_app_ids = IosAppSnapshot.where(released: (Date.today - months_ago.months)..(Date.today + 1.day)).pluck(:ios_app_id)
      if ios_app_ids.present?
        # return IosApp.where("id IN (#{ios_app_ids.join(',')})")
        return IosApp.where(id: ios_app_ids)
      else
        return IosApp.where("id=-1")
      end
    end
    
    def apps_in_categories(categories)
      category_ids = IosAppCategory.where(name: categories).pluck(:id)
      ios_snapshot_ids = IosAppCategoriesSnapshot.where(ios_app_category_id: category_ids).pluck(:ios_app_snapshot_id)
      ios_app_ids = IosAppSnapshot.where(id: ios_snapshot_ids).pluck(:ios_app_id)      
      return IosApp.where(id: ios_app_ids)
    end
    
    def apps_with_keywords(keywords)
      name_query_array = keywords.map{|k| "name LIKE \'%#{k}%\'"}
      name_query_string = name_query_array.join(' OR ')
      snapshots = IosAppSnapshot.where(name_query_string)
      return FilterService.apps_of_snapshots(snapshots)
    end
    
    def companies_with_keywords(keywords)
      name_query_array = keywords.map{|k| "name LIKE \'%#{k}%\'"}
      name_query_string = name_query_array.join(' OR ')
      companies = Company.where(name_query_string)
      return FilterService.apps_of_companies(companies)
    end
    
    def apps_of_companies(companies)
      company_ids = companies.pluck(:id)
      company_website_ids = Website.where(company_id: company_ids).pluck(:id)
      company_app_ids = IosAppsWebsite.where(website_id: company_website_ids).pluck(:ios_app_id)
      return IosApp.where(id: company_app_ids)
    end
    
    def apps_of_snapshots(snapshots)
      app_ids = snapshots.pluck(:ios_app_id)
      return IosApp.where(id: app_ids)
    end
  end
end