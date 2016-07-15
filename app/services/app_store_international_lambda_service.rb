class AppStoreInternationalLambdaService

  class << self
    def trigger_scraping
      batch = Sidekiq::Batch.new
      batch.description = 'AppStoreInternationalLambdaService.trigger_scrapes'
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_trigger',
      )

      batch.jobs do
        AppStoreInternationalQueueWorker.perform_async(:trigger_scrapes)
      end
    end

    def load_snapshots(ios_app_current_snapshot_job_id: IosAppCurrentSnapshotJob.last.id)
      batch = Sidekiq::Batch.new
      batch.description = 'AppStoreInternationalLambdaService.load_snapshots'
      batch.on(
        :complete,
        'AppStoreInternationalService#on_complete_load_snapshots',
      )

      batch.jobs do
        AppStoreInternationalQueueWorker.perform_async(:load_snapshots, ios_app_current_snapshot_job_id)
      end
    end

    def s3_bucket
      Rails.env.production? ? 'ms-ios-international-scrapes' : 'ms-ios-international-scrapes-development'
    end

    def s3_key_path(ios_app_current_snapshot_job, app_identifier, country_code)
      filename = ios_app_current_snapshot_job.created_at.to_s(:number) + '.txt.gz'
      File.join(app_identifier.to_s, country_code, filename)
    end
  end

  def on_complete_trigger(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Completed triggering AWS Lambda functions')
  end

  def on_complete_load_snapshots(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Completed loading snapshots')
  end
end
