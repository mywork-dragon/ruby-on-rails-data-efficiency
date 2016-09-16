# This is only meant to be used by the weekly scrape service (using the temporary proxies)
# For single/live scrapes, use the GooglePlaySnapshotLiveWorker
class GooglePlaySnapshotMassWorker
  include Sidekiq::Worker
  include GooglePlaySnapshotModule

  sidekiq_options queue: :sdk, retry: false

  def proxy_type
    :temporary_proxies
  end

  def scrape_new_similar_apps(similar_apps)
    missing_ids = similar_apps.select { |x| x.id.nil? }
    raise "About to queue #{missing_ids.count} apps without ids: #{missing_ids.map(&:app_identifier).join(', ')}" if missing_ids.count > 0

    batch.jobs do
      similar_apps.each do |android_app|
        GooglePlaySnapshotMassWorker.perform_async(
          @android_app_snapshot_job_id,
          android_app.id
        )
      end
    end
  end
end
