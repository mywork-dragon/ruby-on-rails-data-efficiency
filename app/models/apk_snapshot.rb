class ApkSnapshot < ActiveRecord::Base

  belongs_to :google_account
  belongs_to :android_app
  belongs_to :apk_snapshot_job
  belongs_to :micro_proxy

  has_many :android_sdk_packages_apk_snapshots
  has_many :android_sdk_packages, through: :android_sdk_packages_apk_snapshots

  has_many :android_sdk_companies_apk_snapshots
	has_many :android_sdk_companies, through: :android_sdk_companies_apk_snapshots

  has_many :sdk_packages_apk_snapshots
  has_many :sdk_packages, through: :sdk_packages_apk_snapshots

  has_many :android_sdks_apk_snapshots
  has_many :android_sdks, through: :android_sdks_apk_snapshots

  has_many :apk_snapshots_sdk_js_tags
  has_many :sdk_js_tags, through: :apk_snapshots_sdk_js_tags

  has_many :apk_snapshots_sdk_dlls
  has_many :sdk_dlls, through: :apk_snapshots_sdk_dlls

  has_many :apk_snapshot_exceptions

  belongs_to :apk_file

  before_create :set_dates, :set_try

  # TODO: get rid of unused ones
	enum status: [:failure, :success, :no_response, :forbidden, :taken_down, :could_not_connect, :timeout, :deadlock, :bad_device, :out_of_country, :bad_carrier, :not_found, :unchanged_version, :downloading]
  enum scan_status: [:scan_failure, :scan_success, :invalidated, :scanning]
  enum scan_version: [:first_attempt, :new_years_version] # the version of the scan algorithm

  def set_dates
    x = Time.now
    self.good_as_of_date = x
    self.first_valid_date = x
  end

  def set_try
    self.try = 1
  end

  def invalidate
    self.update(scan_status: :invalidated)

    AndroidApp.find(self.android_app_id).update_newest_apk_snapshot if self.android_app_id
  end

end
