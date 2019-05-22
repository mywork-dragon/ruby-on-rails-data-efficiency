# Used in multiple places

class IosEpfScanService
  class << self

    def scan_new_apps(epf_full_feed_id = nil)
      # Find all apps created after the second to last EPF date
      feed = if epf_full_feed_id.nil?
        EpfFullFeed.last(2).first
      else
        EpfFullFeed.find(epf_full_feed_id)
      end

      released_cutoff = Date.strptime(feed.name, '%Y%m%d')

      apps = IosApp.where('released > ?', released_cutoff)

      puts "Found #{apps.count} newly released apps"

      scan_apps(
        apps.pluck(:id),
        notes: "Running EPF scan on #{Time.now.strftime '%m/%d/%Y'}"
      )
    end

    def scan_new_itunes_apps(ios_app_ids)
      scan_apps(
        ios_app_ids,
        notes: "Scanning #{ios_app_ids.count} missing ios apps from Top 200"
      )
    end

    def scan_apps(ids, notes:)

      ipa_snapshot_job = IpaSnapshotJob.create!(job_type: :mass, notes: notes)

      if Rails.env.production?

        batch = Sidekiq::Batch.new
        batch.description = 'iOS EPF Apps'

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

  def on_complete_scan(status, options)
    # Slackiq.notify(webhook_name: :main, status: status, title: 'Completed iOS Scans')
  end
end
