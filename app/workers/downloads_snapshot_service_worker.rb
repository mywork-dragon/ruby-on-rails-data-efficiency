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
    ios_app_snapshot_job_id = options[:ios_app_snapshot_job_id]

    s = IosAppDownloadSnapshot.create(ios_app: ios_app, ios_app_download_snapshot_job_id: ios_app_download_snapshot_job_id)

    try = 0

    begin

      a = DownloadsService.attributes(app_identifier: ios_app.app_identifier, description: ios_app.description)

      raise 'DownloadsService.attributes is empty' if a.empty?
      
      downloads = a[:downloads]
      
      s.downloads = downloads

      s.save!

    rescue => e
      ise = IosAppDownloadSnapshotException.create(ios_app_snapshot: s, name: e.message, backtrace: e.backtrace, try: try, ios_app_download_snapshot_job_id: ios_app_download_snapshot_job_id)
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

  def test_save_attributes
    ids = [389377362, 801207885, 509978909, 946286572, 355074115]

    android_app_ids = ids.map{ |id| AndroidApp.find_or_create_by(app_identifier: id) }

    perform(-1, ios_app_ids)
  end
  
end