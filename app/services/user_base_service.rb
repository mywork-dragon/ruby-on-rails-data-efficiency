# Calculates user bases for apps
module UserBaseService

  class Ios

    class << self

      def minimum_metrics_for_store(app_store_id, user_base)
        scaling_factors = AppStoreScalingFactor.find_by_app_store_id!(app_store_id)
        raise MalformedData unless scaling_factors.ratings_all_count && scaling_factors.ratings_per_day_current_release
        {
          count: lower_bounds[user_base][:count] * scaling_factors.ratings_all_count,
          rpd: lower_bounds[user_base][:rpd] * scaling_factors.ratings_per_day_current_release
        }
      end

      # defines lower bounds for metrics for US numbers
      def lower_bounds
        {
          weak: {
            count: 0,
            rpd: 0
          },
          moderate: {
            count: 100,
            rpd: 0.1
          },
          strong: {
            count: 10e3,
            rpd: 1
          },
          elite: {
            count: 50e3,
            rpd: 7
          }
        }
      end

    end

  end

  class Android
  end

end
