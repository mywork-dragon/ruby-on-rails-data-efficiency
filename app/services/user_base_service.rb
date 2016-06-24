# Calculates user bases for apps
module UserBaseService

  class Ios

    class << self

      def user_base_for_app_store(app_store:, ratings_all_count:, ratings_per_day_current_release:)
        if ratings_all_count && ratings_per_day_current_release

          ratings_all_count_scaled = ratings_all_count * ratings_all_scale_factor
          ratings_per_day_current_release_scaled = ratings_per_day_current_release * ratings_current_scale_factor

          if ratings_per_day_current_release_scaled >= 7 || ratings_all_count_scaled >= 50e3
            user_base = :elite
          elsif ratings_per_day_current_release_scaled >= 1 || ratings_all_count_scaled >= 10e3
            user_base = :strong
          elsif ratings_per_day_current_release_scaled >= 0.1 || ratings_all_count_scaled >= 100
            user_base = :moderate
          else
            user_base = :weak
          end
          
          return user_base
        end

        nil
      end

      # Multiply  by this scale factor to match US criteria
      def ratings_current_scale_factor(app_store)
        return 1.0 if app_store.country_code == 'us'

        n_top = 100   # number of top apps to sample
        app_store_us = AppStore.find_by_country_code('us')

        ratings_current_count = IosAppCurrentSnapshot.where(is_valid: true, app_store: app_store).order("ratings_current_count DESC").limit(n_top).pluck(:ratings_current_count)
        return nil if ratings_current_count.count != n_top
        ratings_current_count_us = IosAppCurrentSnapshot.where(is_valid: true, app_store: app_store_us).order("ratings_current_count DESC").limit(n_top).pluck(:ratings_current_count)

        avg = (ratings_current_count.sum / ratings_current_count.count.to_f).to_f
        avg_us = (ratings_current_count_us.sum / ratings_current_count_us.count.to_f).to_f

        avg / avg_us #scale is relative to USA
      end

      # Multiply by this scale factor to match US criteria
      def ratings_all_scale_factor(app_store)
        return 1.0 if app_store.country_code == 'us'

        n_top = 100   # number of top apps to sample
        app_store_us = AppStore.find_by_country_code('us')

        ratings_all_count = IosAppCurrentSnapshot.where(is_valid: true, app_store: app_store).order("ratings_all_count DESC").limit(n_top).pluck(:ratings_all_count)
        return nil if ratings_all_count.count != n_top
        ratings_all_count_us = IosAppCurrentSnapshot.where(is_valid: true, app_store: app_store_us).order("ratings_all_count DESC").limit(n_top).pluck(:ratings_all_count)

        avg = (ratings_all_count.sum / ratings_all_count.count.to_f).to_f
        avg_us = (ratings_all_count_us.sum / ratings_all_count_us.count.to_f).to_f
        
        avg / avg_us #scale is relative to USA
      end

    end

  end

  class Android
  end

end