# Calculates user bases for apps
# Used in a couple of places

module UserBaseService

  class Ios

    class << self

      def minimum_metrics_for_store(app_store_id, user_base)
        scaling_factors = scaling_factor_details[app_store_id] || scaling_factor_details[1]
        raise MalformedData unless scaling_factors[:ratings_all_count_scaling] && scaling_factors[:ratings_per_day_current_release_scaling]
        {
          count: lower_bounds[user_base][:count] * scaling_factors[:ratings_all_count_scaling],
          rpd: lower_bounds[user_base][:rpd] * scaling_factors[:ratings_per_day_current_release_scaling]
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

      private

      # These scaling factors were calculated on 06/20/2017 by taking the top 100,000 apps
      # in each region with regards to total rating count and daily ratings.
      def scaling_factor_details
        {
          1 => scaling_hash(2398.63544, 1.0, 1.2530845, 1.0),
          2 => scaling_hash(526.17989, 0.21936634522501677, 0.4361451, 0.3480572140186875),
          3 => scaling_hash(443.73393, 0.18499431910336486, 0.1875706, 0.1496871120822259),
          4 => scaling_hash(15.23927, 0.0063533081125491915, 0.0073129, 0.005835919285570926),
          5 => scaling_hash(1458.3032, 0.6079720059501831, 3.931978, 3.1378394673304157),
          11 => scaling_hash(176.89618, 0.07374867270367688, 0.0797458, 0.06363960291584488),
          22 => scaling_hash(96.4476, 0.040209361702752126, 0.0933055, 0.07446066087322922),
          38 => scaling_hash(240.73889, 0.10036493498987074, 0.1871383, 0.14934212337635652),
          50 => scaling_hash(249.89161, 0.10418073786152346, 0.1014384, 0.08095096539778443),
          75 => scaling_hash(135.21186, 0.05637032528794789, 0.0722845, 0.05768525586263337),
          121 => scaling_hash(245.028, 0.10215308083666103, 0.1945239, 0.155236059499578)
        }
      end

      def scaling_hash(ratings_counts, ratings_counts_scaling, daily_ratings, daily_ratings_scaling)
        return {
          :ratings_all_count => ratings_counts,
          :ratings_all_count_scaling => ratings_counts_scaling,
          :ratings_per_day_current_release => daily_ratings,
          :ratings_per_day_current_release_scaling => daily_ratings_scaling
        }
      end

    end

  end

  class Android
  end

end
