# Temporary implentation. It lazily retrieves some stub rankings data from S3
# and stores them in memory. The size of the files total to 1.3MB.
#
# The current data is only in US and does not have a timestamp.  So this
# implementation will always return data as if the entries were created one
# day ago.
class MockRankingsAccessor

  def initialize
    @s3_client ||= MightyAws::S3.new
  end

  def get_trending(platforms:[], countries:[], categories:[], rank_types:[], size: 20, page_num: 1, sort_by: "weekly_change", desc: true)
    load_trending_data if @trending_data.nil?

    trending_data_dict = {}
    @trending_data.each do |trending_datum|
      if matches_filters(trending_datum, platforms, countries, categories, rank_types)
        app_id = trending_datum["app_identifier"]
        if trending_data_dict[app_id].nil? or trending_data_dict[app_id][sort_by] < trending_datum["change"]
          trending_data_dict[app_id] = copy_trending_record(trending_datum)
        end
      end
    end

    trending_list = trending_data_dict.values
    reverser = desc ? -1 : 1
    trending_list.sort! { |a, b| (a[sort_by].to_i <=> b[sort_by].to_i) * reverser }
    {
      "total" => trending_data_dict.values.size,
      "apps" => trending_list.slice((size * (page_num - 1)), size)
    }
  end

  # Ignores lookback_time, all data is always 1 day ago
  def get_newcomers(platforms:[], countries:[], categories:[], rank_types:[], lookback_time: 14.days.ago, size: 20, page_num: 1)
    load_newcomers_data if @newcomers_data.nil?

    return_list = []
    @newcomers_data.each do |newcomer_datum|
      if matches_filters(newcomer_datum, platforms, countries, categories, rank_types)
        return_list.push(copy_newcomer_record(newcomer_datum))
      end
    end

    return_list.sort! { |a, b| (a["rank"].to_i <=> b["rank"].to_i) }
    {
      "total" => return_list.size,
      "apps" => return_list.slice((size * (page_num - 1)), size)
    }
  end

  def get_chart(platform:, country:, category:, rank_type:, size: 20, page_num: 1)
    nil # TODO
  end

private

  def copy_newcomer_record(record)
    {
      "app_identifier" => record["app_identifier"],
      "date" => 1.days.ago,
      "platform" => record["platform"],
      "country" => record["country"],
      "category" => record["category"],
      "ranking_type" => record["ranking_type"],
      "rank" => record["rank"]
    }
  end

  def copy_trending_record(record)
    {
      "app_identifier" => record["app_identifier"],
      "platform" => record["platform"],
      "weekly_change" => record["change"],
      "monthly_change" => record["change"],
      "previous_rank" => record["previous_rank"],
      "current_rank" => record["current_rank"],
      "country" => record["country"],
      "category" => record["category"],
      "ranking_type" => record["ranking_type"]
    }
  end
  
  def matches_filters(record, platforms, countries, categories, rank_types)
    (platforms.empty? or platforms.include?(record["platform"])) and
    (countries.empty? or countries.include?(record["country"])) and
    (categories.empty? or categories.include?(record["category"])) and
    (rank_types.empty? or rank_types.include?(record["ranking_type"]))
  end

  def normalize_ranking_type(platform, type)
    if platform == "ios"
      return {
        "27" => "free",
        "30" => "paid",
        "38" => "grossing"
      }[type]
    elsif platform == "android"
      return {
        "topselling_free" => "free",
        "topselling_paid" => "paid",
        "topselling_new_paid" => "unused",
        "topselling_new_free" => "unused",
        "topgrossing" => "grossing",
      }[type]
    end
  end

  def load_newcomers_data
    ios_newcomers = JSON.parse(@s3_client.retrieve(
        bucket: "ms-misc",
        key_path: "charts-mock-data/ios_us_chart_newcomers.json.gz"
      ))
    ios_newcomers.map! do |datum|
      datum["country"] = "US" # just default everything to US for now
      datum["platform"] = "ios"
      datum["ranking_type"] = normalize_ranking_type("ios", datum["ranking_type"])
      datum
    end
    
    android_newcomers = JSON.parse(@s3_client.retrieve(
        bucket: "ms-misc",
        key_path: "charts-mock-data/android_us_chart_newcomers.json.gz"
      ))
    android_newcomers.map! do |datum|
      datum["country"] = "US" # just default everything to US for now
      datum["platform"] = "android"
      datum["ranking_type"] = normalize_ranking_type("android", datum["ranking_type"])
      datum
    end

    @newcomers_data = ios_newcomers + android_newcomers
  end

  def load_trending_data
    ios_trending = JSON.parse(@s3_client.retrieve(
      bucket: "ms-misc",
      key_path: "charts-mock-data/ios_us_chart_trends.json.gz"))
    ios_trending.map! do |datum|
      datum["country"] = "US" # just default everything to US for now
      datum["platform"] = "ios"
      datum["ranking_type"] = normalize_ranking_type("ios", datum["ranking_type"])
      datum
    end
    
    android_trending = JSON.parse(@s3_client.retrieve(
      bucket: "ms-misc",
      key_path: "charts-mock-data/android_us_chart_trends.json.gz"))
    android_trending.map! do |datum|
      datum["country"] = "US" # just default everything to US for now
      datum["platform"] = "android"
      datum["ranking_type"] = normalize_ranking_type("android", datum["ranking_type"])
      datum
    end

    @trending_data = ios_trending + android_trending
  end

end