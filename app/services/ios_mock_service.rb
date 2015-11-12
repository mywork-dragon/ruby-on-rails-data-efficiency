class IosMockService

  class << self

    # pass an array of app identifiers
    def mock(app_identifiers)

      return "Nothing to run" if app_identifiers.nil?

      job_id = IpaSnapshotJob.create!(notes: "running a mock ios scan job on apps #{app_identifiers.join(',')}", job_type: :mock).id

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
      job = IpaSnapshotJob.create!(type: :mock)
      snap = IpaSnapshot.create!(ios_app_id: 364297166, ipa_snapshot_job_id: job.id)
    end

  end
end