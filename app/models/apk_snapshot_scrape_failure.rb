# == Schema Information
#
# Table name: apk_snapshot_scrape_failures
#
#  id                  :integer          not null, primary key
#  android_app_id      :integer
#  reason              :integer
#  scrape_content      :text(65535)
#  created_at          :datetime
#  updated_at          :datetime
#  version             :string(191)
#  apk_snapshot_job_id :integer
#

class ApkSnapshotScrapeFailure < ActiveRecord::Base
  belongs_to :android_app
  belongs_to :apk_snapshot_job

  enum reason: [:unchanged_version, :paid, :not_found, :unavailable, :bad_google_scrape]
end
