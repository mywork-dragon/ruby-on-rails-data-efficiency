class ItunesChartsRankingsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :itunes_charts_rankings, retry: 5

  def perform(storefront_id)
    ItunesTopChartsRankings.request_for(storefront_id)
  end
end
