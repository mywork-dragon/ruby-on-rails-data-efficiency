class IosEpfScanService
  class << self

    def scan_epf_apps(ids)

      ipa_snapshot_job = IpaSnapshotJob.create!(job_type: :mass, notes: "Running EPF scan on #{Time.now.strftime '%m/%d/%Y'}")

      if Rails.env.production?

        Slackiq.message("Starting iOS EPF Scan for #{ids.length}", webhook_name: :main)
        
        batch = Sidekiq::Batch.new
        batch.description = 'iOS EPF Apps'
        batch.on(:complete, 'IosEpfScanService#on_epf_complete')

        batch.jobs do
          IosApp.where(id: ids).pluck(:id).each do |id|
            IosEpfScanServiceWorker.perform_async(ipa_snapshot_job.id, id)
          end
        end

      else

        IosApp.where(id: ids).limit(1).each do |ios_app|
          IosEpfScanServiceWorker.new.perform(ipa_snapshot_job.id, ios_app.id)
        end
      end
    end
  end

  def on_epf_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Completed iOS Scans for EPF')
  end
end