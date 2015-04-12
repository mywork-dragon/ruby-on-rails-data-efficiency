class DownloadsSnapshotService
  
  class << self
    
    def run(notes, options={})

      j = IosAppDownloadSnapshotJob.create!(notes: notes)

      IosApp.find_each.with_index do |ios_app, index|
        li "App ##{index}" if index%10000 == 0
        DownloadsSnapshotServiceWorker.perform_async(j.id, ios_app.id)
      end

    end
    
    def apps_per_minute(ios_app_download_snapshot_job_id=IosAppDownloadSnapshotJob, sample_seconds=10)
      a = IosAppDownloadSnapshot.where(ios_app_download_snapshot_job_id: ios_app_download_snapshot_job_id:).count
      sleep sample_seconds
      b = IosAppDownloadSnapshot.where(ios_app_download_snapshot_job_id: ios_app_download_snapshot_job_id:).count
      60.0/sample_seconds*(b-a)
    end

    def apps_per_hour(ios_app_download_snapshot_job_id=IosAppDownloadSnapshotJob.last.id, sample_seconds=10)
      apps_per_minute(ios_app_download_snapshot_job_id, sample_seconds)*60.0
    end

    def apps_per_day(ios_app_download_snapshot_job_id=IosAppDownloadSnapshotJob.last.id, sample_seconds=10)
      apps_per_hour(ios_app_download_snapshot_job_id, sample_seconds)*24.0
    end

    def hours_per_job(ios_app_download_snapshot_job_id=IosAppDownloadSnapshotJob.last.id, sample_seconds=10)
      IosApp.count * (1.0 / apps_per_hour(ios_app_download_snapshot_job_id, sample_seconds))
    end
    
  end
  
end