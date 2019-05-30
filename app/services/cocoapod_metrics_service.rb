class CocoapodMetricsService

  class << self

    def update_metrics

      pod_sdks = IosSdk.find(Cocoapod.select(:ios_sdk_id).map{|x| x.ios_sdk_id}.compact.uniq)

      if Rails.env.production?
        batch = Sidekiq::Batch.new
        batch.description = "updating metrics for cocoapods" 
        batch.on(:complete, 'CocoapodMetricsService#on_complete')

        batch.jobs do
          pod_sdks.each do |sdk|
            row = CocoapodMetric.create!(ios_sdk_id: sdk.id)
            CocoapodMetricsServiceWorker.perform_async(row.id)
          end
        end
      else
        pod_sdks.sample(2).each do |sdk|
          row = CocoapodMetric.create!(ios_sdk_id: sdk.id)
          CocoapodMetricsServiceWorker.new.perform(row.id)
        end
      end
    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'updated_metrics')
  end
end