class AppStoreInternationalTriggerWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: 1, queue: :default

  def perform(ios_app_current_snapshot_job_id, app_identifiers)
    job = IosAppCurrentSnapshotJob.find(ios_app_current_snapshot_job_id)
    country_codes = AppStore.where(enabled: true).pluck(:country_code)

    country_codes.each_with_index do |country_code, index|
      puts "Triggering country #{index}: #{country_code}"
      app_identifiers.each do |app_identifier|
        MightyAws::Sns.new.trigger_ios_app_scrape(
          app_identifier: app_identifier,
          country_code: country_code,
          bucket: AppStoreInternationalLambdaService.s3_bucket,
          s3_key_path: AppStoreInternationalLambdaService.s3_key_path(job, app_identifier, country_code)
        )
      end
    end
  end
end
