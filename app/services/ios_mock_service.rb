class IosMockService

  class << self

    # pass an array of app identifiers
    def mock(app_identifiers)

      return "Nothing to run" if app_identifiers.nil?

      job_id = IpaSnapshotJob.create!(notes: "running a mock ios scan job on apps #{app_identifiers.join(',')}", type: :mock).id

      if Rails.env.production?

        batch = Sidekiq::Batch.new
        batch.description = "running a mock ios scan job"
        bid = batch.bid

        batch.jobs do
          app_identifiers.each do |app_id|
            IosSingleScanServiceWorker.perform_async(job_id, app_id, bid)
          end
        end
      else
        app_identifiers.each do |app_id|
          IosScanSingleServiceWorker.new.perform(job_id, app_id)
        end
      end
    end

    def test_on_complete
      nil
    end

  end
end