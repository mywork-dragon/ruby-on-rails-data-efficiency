class ApkSnapshotScrapeFailure < ActiveRecord::Base
  belongs_to :android_app
  belongs_to :apk_snapshot_job

  enum reason: [:unchanged_version]
end
