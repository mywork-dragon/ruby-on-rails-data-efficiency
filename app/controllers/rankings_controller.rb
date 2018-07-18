class RankingsController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :authenticate_admin_account

  def get_android_category_objects
    ra = RankingsAccessor.new
    render json: AndroidAppCategory.where(category_id: ra.android_categories)
  end

  def get_ios_category_objects
    ra = RankingsAccessor.new
    render json: IosAppCategory.where(category_identifier: ra.ios_categories)
  end

  def get_historical_app_rankings
    app_identifier = params['app_identifier']
    platform = params['platform']
    countries = JSON.parse(params['countries']) || []
    categories = params['categories'] ? JSON.parse(params['categories']) : []
    rank_types = params['rank_types'] ? JSON.parse(params['rank_types']) : []
    min_date = params['min_date'] ? Date.parse(params['min_date']) : 30.days.ago
    max_date = params['max_date'] ? Date.parse(params['max_date']) : Time.now.end_of_day

    results = RankingsAccessor.new.get_historical_app_rankings(
      app_identifier: app_identifier,
      platform: platform,
      countries: countries,
      categories: categories,
      rank_types: rank_types,
      min_date: min_date.strftime('%Y-%m-%d'),
      max_date: max_date.strftime('%Y-%m-%d'),
    )

    # group ranks by chart

    charts = {}
    results.each do |result|
      id = "#{result['country']}#{result['category']}#{result['ranking_type']}"
      rank = [result['created_at'].strftime("%Y-%m-%d"), result['rank']]
      existingChart = charts[id]
      if existingChart
        existingChart['ranks'].push(rank)
      else
        charts[id] = {
          "country" => result['country'],
          "category" => result['category'],
          "rank_type" => result['ranking_type'],
          "ranks" => [rank],
        }
      end
    end

    render json: charts.values
  end

end
