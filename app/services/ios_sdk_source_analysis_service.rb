class IosSdkSourceAnalysisService
  class << self
    def find_sdk_similarities(sdk_names = nil)
      sdks = sdk_names.nil? ? IosSdk.select(:id) : IosSdk.where(name: sdk_names)

      if Rails.env.production?
        batch = Sidekiq::Batch.new
        batch.description = "Computing ios sdk source matches" 
        batch.on(:complete, 'IosSdkSourceAnalysisService#on_complete')

        batch.jobs do
          sdks.each do |sdk|
            IosSdkSourceAnalysisWorker.perform_async(sdk.id)
          end
        end
      else
        sdks.sample(1).each do |sdk|
          IosSdkSourceAnalysisWorker.new.perform(sdk.id)
        end
      end
    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'analyzed_ios_sdk_source')
  end
end