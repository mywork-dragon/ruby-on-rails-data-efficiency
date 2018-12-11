# == Schema Information
#
# Table name: apk_snapshot_scrape_exceptions
#
#  id                  :integer          not null, primary key
#  apk_snapshot_job_id :integer
#  error               :text(65535)
#  backtrace           :text(65535)
#  android_app_id      :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class ApkSnapshotScrapeException < ActiveRecord::Base
  belongs_to :apk_snapshot_job
  belongs_to :android_app
end
