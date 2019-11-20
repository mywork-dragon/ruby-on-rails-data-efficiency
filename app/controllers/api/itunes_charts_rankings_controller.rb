class Api::ItunesChartsRankingsController < ApplicationController
  def request_charts_rankings
    # receive params here and enqueue the job
    storefront_id = params[:storefront_id]
    ItunesChartService.get_storefront_charts(storefront_id)
    head :ok
  end
end
