class ApkSnapshotScrapeException < ActiveRecord::Base
  belongs_to :apk_snapshot_job
  belongs_to :android_app
end
