class Api::HistoricalAppRankingsController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_action :set_current_user, :authenticate_request

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
