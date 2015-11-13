class IosMockService

  class << self

    def mock_multiple_live_scans(app_identifiers)

      return "Nothing to run" if app_identifier.nil?

      job_id = IpaSnapshotJob.create!(notes: "running multiple live scan jobs on #{app_identifier.join(',')}", job_type: :mock).id

      if Rails.env.production?

        batch = Sidekiq::Batch.new
        batch.description = "running a mock ios scan job"
        bid = batch.bid

        batch.jobs do
          app_identifiers.each do |app_id|
            IosMockServiceWorker.perform_async(job_id, app_identifier, :one_off, bid)
          end
        end
      else
        raise "You probably don't want to scan multiple ios apps in development mode"
      end  
    end



    def mock_live_scan(app_identifier)

      return "Nothing to run" if app_identifier.nil?

      job_id = IpaSnapshotJob.create!(notes: "running a single live scan job on app #{app_identifier}", job_type: :mock).id

      if Rails.env.production?

        batch = Sidekiq::Batch.new
        batch.description = "running a mock ios scan job"
        bid = batch.bid

        batch.jobs do
          IosMockServiceWorker.perform_async(job_id, app_identifier, :one_off, bid)
        end
      else
        IosMockServiceWorker.new.perform(job_id, app_identifier, :one_off)
      end
    end
  end
end