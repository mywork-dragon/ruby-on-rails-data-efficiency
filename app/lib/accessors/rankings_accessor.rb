class RankingsAccessor

  attr_reader :delegate

  def initialize
    @delegate = RedshiftRankingsAccessor.new
  end

  # Returns a list of apps that have moved postions on a top chart. If an app appears on more than one top
  # chart, the chart in which the app jumped the most is returned. If any of the platforms, countries, categories,
  # rank_types parameters are left out, it is treated as a wildcard.
  #
  # By default the list is sorted by the highest weekly change first. Sorting can be toggled via the sort_by
  # ("weekly_change", "monthly_change", "rank") and desc parameters.
  #
  #
  #
  # Possible values for parameters:
  #
  #   platforms: "ios", "android"
  #   countries: two letter code of country based on "ISO 3166-1 alpha-2" standard
  #   categories: these values ARE NOT NORMALIZED between platforms. For iOS, this is the category id (e.g. "7015"),
  #               on Android this is the human readable category name ("GAME")
  #   rank_types: "free", "paid", "grossing"
  #
  #
  #
  # Return Format:
  #   {
  #       total: xxxxx,
  #       apps: [
  #           {
  #               app_identifier: xxxxx,
  #               weekly_change: xxxxx,
  #               monthly_change: xxxxx,
  #               rank: xxxxx,
  #               platform: xxxxxx,
  #               country: xxxxxx,
  #               category: xxxxxx,
  #               ranking_type: xxxxxx
  #           },
  #           ...
  #       ]
  #   }
  def get_trending(platforms:[], countries:[], categories:[], rank_types: ["free", "paid", "grossing"], size: 20, page_num: 1, sort_by: "weekly_change", desc: true, max_rank: 500)
    return @delegate.get_trending(platforms:platforms, countries:countries, categories:categories, rank_types:rank_types, size: size, page_num: page_num, sort_by: sort_by, desc: desc, max_rank: max_rank)
  end

  # Returns a list of apps that have shown up for the first time on a specific chart, within the specifed lookback time.
  # If any of the platforms, countries, categories, rank_types parameters are left out, it is treated as a wildcard. If
  # an app shows up for the first time on multiple charts, this function will return an object for each of the charts.
  #
  # The return list is sorted by created_at (i.e. date that the app entered the chart).
  #
  #
  #
  # Possible values for parameters:
  #
  #   platforms: "ios", "android"
  #   countries: two letter code of country based on "ISO 3166-1 alpha-2" standard
  #   categories: these values ARE NOT NORMALIZED between platforms. For iOS, this is the category id (e.g. "7015"),
  #               on Android this is the human readable category name ("GAME")
  #   rank_types: "free", "paid", "grossing"
  #
  # Return Format:
  #
  #   {
  #       total: xxxxx,
  #       apps: [
  #            {
  #                app_identifier: xxxxx,
  #                created_at: xxxxx,
  #                platform: xxxx,
  #                category: xxxx,
  #                ranking_type: xxxx,
  #                country: xxxxx,
  #                rank: xxxxx
  #            },
  #            ...
  #       ]
  #   }
  def get_newcomers(platforms:[], countries:[], categories:[], rank_types: ["free", "paid", "grossing"], lookback_time: 14.days.ago, size: 20, page_num: 1, sort_by: "created_at", desc: true, max_rank: 500)
    return @delegate.get_newcomers(platforms:platforms, countries:countries, categories:categories, rank_types:rank_types, lookback_time: lookback_time, size: size, page_num: page_num, sort_by: sort_by, desc: desc, max_rank: max_rank)
  end

  # Returns the raw chart with the give parameters.
  #
  # The return list is sorted by rank.
  #
  #
  #
  # Possible values for parameters:
  #
  #   platform: "ios", "android"
  #   country: two letter code of country based on "ISO 3166-1 alpha-2" standard
  #   category: these values ARE NOT NORMALIZED between platforms. For iOS, this is the category id (e.g. "7015"),
  #               on Android this is the human readable category name ("GAME")
  #   rank_type: "free", "paid", "grossing"
  #
  # Return Format:
  #
  #   {
  #       total: xxxxx,
  #       apps: [
  #            {
  #                app_identifier: xxxxx,
  #                created_at: xxxxx,
  #                platform: xxxx,
  #                category: xxxx,
  #                ranking_type: xxxx,
  #                country: xxxxx,
  #                rank: xxxxx
  #            },
  #            ...
  #       ]
  #   }
  def get_chart(platform:, country:, category:, rank_type:, size: 20, page_num: 1)
    return @delegate.get_chart(platform: platform, country: country, category: category, rank_type:rank_type, size: size, page_num: page_num)
  end

  def ios_countries
    return @delegate.ios_countries
  end

  def ios_categories
    return @delegate.ios_categories
  end

  def android_countries
    return @delegate.android_countries
  end

  def android_categories
    return @delegate.android_categories
  end

  # Returns unique app_identifiers in the daily_newcomers_swap table. Currently used to kick off
  # scrapes for missing Android apps.
  def unique_newcomers(platform:, lookback_time:, page_size:, page_num:, count: false)
    return @delegate.unique_newcomers(platform: platform, lookback_time: lookback_time, page_size: page_size, page_num: page_num, count: count)
  end

  def get_historical_app_rankings(app_identifier:, platform:, countries:, categories:, rank_types:, min_date:, max_date:)
    return @delegate.get_historical_app_rankings(
      app_identifier: app_identifier,
      platform: platform,
      countries: countries,
      categories: categories,
      rank_types: rank_types,
      min_date: min_date,
      max_date: max_date
    )
  end

end
