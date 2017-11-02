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
  # ("weekly_change", "monthly_change") and desc parameters.
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
  #               highest_rank: xxxxx,
  #               platform: xxxxxx,
  #               country: xxxxxx,
  #               category: xxxxxx,
  #               ranking_type: xxxxxx
  #           },
  #           ...
  #       ]
  #   }
  def get_trending(platforms:[], countries:[], categories:[], rank_types:[], size: 20, page_num: 1, sort_by: "weekly_change", desc: true)
    return @delegate.get_trending(platforms:platforms, countries:countries, categories:categories, rank_types:rank_types, size: size, page_num: page_num, sort_by: sort_by, desc: desc)
  end

  # Returns a list of apps that have shown up for the first time on a specific chart, within the specifed lookback time.
  # If any of the platforms, countries, categories, rank_types parameters are left out, it is treated as a wildcard. If
  # an app shows up for the first time on multiple charts, this function will return an object for each of the charts.
  #
  # The return list is sorted by highest rank.
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
  #                date: xxxxx,
  #                platform: xxxx,
  #                category: xxxx,
  #                ranking_type: xxxx,
  #                country: xxxxx,
  #                rank: xxxxx
  #            },
  #            ...
  #       ]
  #   }
  def get_newcomers(platforms:[], countries:[], categories:[], rank_types:[], lookback_time: 14.days.ago, size: 20, page_num: 1)
    return @delegate.get_newcomers(platforms:platforms, countries:countries, categories:categories, rank_types:rank_types, lookback_time: lookback_time, size: size, page_num: page_num)
  end

  def get_chart(platform:, country:, category:, rank_type:, size: 20, page_num: 0)
    return @delegate.get_chart(platform: platform, country: country, category: category, rank_type:rank_type, size: 20, page_num: 1)
  end

end