class DownloadsSnapshotServiceWorker
  include Sidekiq::Worker

  # accounting for retries ourself, so disable sidekiq retries
  sidekiq_options retry: false

  MAX_TRIES = 3

  def perform(ios_app_download_snapshot_job_id, ios_app_id)

    save_attributes(ios_app_id: ios_app_id, ios_app_download_snapshot_job_id: ios_app_download_snapshot_job_id)

  end

  def save_attributes(options={})
    ios_app = IosApp.find(options[:ios_app_id])
    ios_app_download_snapshot_job_id = options[:ios_app_download_snapshot_job_id]

    s = IosAppDownloadSnapshot.create(ios_app: ios_app, ios_app_download_snapshot_job_id: ios_app_download_snapshot_job_id)

    try = 0

    begin
      
      name = nil
      
      recent_snapshots = IosAppSnapshot.where(ios_app: ios_app).order(created_at: :desc).limit(5)
      
      recent_snapshots.each do |rss| 
        if rss_name = rss.name
          name = rss_name
          break
        end
      end
      
      app_identifier = ios_app.app_identifier
      
      # name = 'Dropbox'
      # app_identifier = 327630330
      
      raise "Couldn't find name in any recent snapshots" if name.nil?
      
      a = DownloadsService.attributes(app_identifier: app_identifier, name: name)

      raise 'DownloadsService.attributes is empty' if a.empty?
      
      downloads = a[:downloads]
      
      s.downloads = downloads

      s.save!

    rescue => e
      ise = IosAppDownloadSnapshotException.create(ios_app_download_snapshot: s, name: e.message, backtrace: e.backtrace, try: try, ios_app_download_snapshot_job_id: ios_app_download_snapshot_job_id)
      if (try += 1) < MAX_TRIES
        retry
      else
        s.status = :failure
        s.save!
      end
    else
      s.status = :success
      s.save!
    end

    s
  end
  
end