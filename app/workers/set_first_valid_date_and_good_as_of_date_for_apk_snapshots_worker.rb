class SetFirstValidDateAndGoodAsOfDateForApkSnapshotsWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :sdk

  def perform(apk_snapshot_id)
    ss = ApkSnapshot.find(apk_snapshot_id)
    created_at = ss.created_at
    ss.first_valid_date = created_at if ss.first_valid_date.blank?
    ss.good_as_of_date = created_at if ss.good_as_of_date.blank?
    ss.save!
  end

end