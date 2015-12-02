class IosMockService

  class << self

    def mock_multiple_live_scans(app_identifiers)

      raise "No longer in use"

      return "Nothing to run" if app_identifiers.nil?

      job_id = IpaSnapshotJob.create!(notes: "running multiple live scan jobs on app identifiers #{app_identifiers.join(', ')}", job_type: :mock).id

      if Rails.env.production?

        batch = Sidekiq::Batch.new
        batch.description = "running a mock ios scan job"
        bid = batch.bid

        batch.jobs do
          app_identifiers.each do |app_identifier|
            ios_app_id = IosApp.find_by_app_identifer(app_identifier)
            IosLiveScanServiceWorker.perform_async(job_id, ios_app_id)
          end
        end
      else
        raise "You probably don't want to scan multiple ios apps in development mode"
      end  
    end



    def mock_live_scan(app_identifier)

      raise "No longer in use"

      return "Nothing to run" if app_identifier.nil?

      ios_app = IosApp.find_by_app_identifier(app_identifier)

      return "No app by app identifier #{app_identifier}" if !ios_app.present?

      job_id = IpaSnapshotJob.create!(notes: "running a single live scan job on app identifier #{app_identifier}", job_type: :mock).id

      if Rails.env.production?

        batch = Sidekiq::Batch.new
        batch.description = "running a mock ios scan job"
        bid = batch.bid

        batch.jobs do
          IosLiveScanServiceWorker.perform_async(job_id, ios_app.id)
        end
      else
        IosLiveScanServiceWorker.new.perform(job_id, ios_app.id)
      end
    end
  end
end