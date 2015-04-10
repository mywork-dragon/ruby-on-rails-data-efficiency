class GooglePlaySnapshotService
  
  
  class << self

    def run(notes, options={})

      j = AndroidAppSnapshotJob.create!(notes: notes)

      AndroidApp.find_each.with_index do |android_app, index|
        li "App ##{index}" if index%10000 == 0
        GooglePlaySnapshotServiceWorker.perform_async(j.id, android_app.id)
      end

    end

    def apps_per_minute(android_app_snapshot_job_id, sample_seconds=10)
      AndroidAppSnapshot.where(android_app_snapshot_job_id: android_app_snapshot_job_id).count
      sleep sample_seconds
      b = AndroidAppSnapshot.where(android_app_snapshot_job_id: android_app_snapshot_job_id).count
      60.0/sample_seconds*(b-a)
    end

    def apps_per_hour(android_app_snapshot_job_id, sample_seconds=10)
      apps_per_minute(android_app_snapshot_job_id, sample_seconds)*60.0
    end

    def apps_per_day(android_app_snapshot_job_id, sample_seconds=10)
      apps_per_hour(android_app_snapshot_job_id, sample_seconds)*24.0
    end

    def hours_per_job(android_app_snapshot_job_id, sample_seconds=10)
      AndroidApp.count * (1.0 / apps_per_hour(android_app_snapshot_job_id, sample_seconds))
    end

  end
  
end