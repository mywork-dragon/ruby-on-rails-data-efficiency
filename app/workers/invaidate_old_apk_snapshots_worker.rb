class InvalidateOldApkSnapshotsWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :sdk

  def perform(android_app_id)
    aa = AndroidApp.find(android_app_id)
    return if aa.blank?

    newest_ss = aa.newest_apk_snapshot

    return if newest_ss.blank?

    invalids = aa.apk_snapshots.where(scan_status: ApkSnapshot.scan_statuses[:scan_success]).where.not(id: newest_ss.id)

    invalids.each do |invalid_ss|
      invalid_ss.scan_status = ApkSnapshot.scan_statuses[:invalidated]
      invalid_ss.save!
    end
  end

end