class IosSdkFaviconService
  class << self

    def retry_google_favicons(ios_sdk_ids: nil)

      if ios_sdk_ids.present?
        sdks = IosSdk.find(ios_sdk_ids)
      else
        sdks = IosSdk.where('favicon REGEXP s2/favicons')
      end

      if Rails.env.production?
        batch = Sidekiq::Batch.new
        batch.description = "updating the google favicons for ios sdks" 
        batch.on(:complete, 'IosSdkFaviconService#on_complete')

        batch.jobs do
          sdks.each do |sdk|
            IosSdkFaviconServiceWorker.perform_async(sdk.id)
          end
        end
      else
        sdks.sample do |sdk|
          IosSdkFaviconServiceWorker.new.perform(sdk.id)
        end
      end

    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'updated ios sdk favicons')
  end
end