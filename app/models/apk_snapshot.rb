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

  include ProxyRegions

  def set_region(region)
    self.android_app.add_region(region)
    self.android_app.save!
    self.region = region
  end

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

  def s3_client
    @s3_client ||= MightyAws::S3.new(Rails.application.config.app_pkg_summary_bucket_region)
    @s3_client
  end

  def classification_summary_s3_key
    ident = Digest::SHA1.hexdigest(id.to_s)
    "classification_summaries/#{ident}.gz"
  end

  def store_classification_summary(classes_to_sdks)
    # Uploads an sdk summary to s3.
    summary = {
      apk_snapshot_id: id,
      app_id: android_app.id,
      app_identifier: android_app.app_identifier,
      apk_snapshot_created: created_at,
      sdks: android_sdks.pluck(:name),
      classes_to_sdks: classes_to_sdks,
    }

    s3_client.store(
      bucket: Rails.application.config.app_pkg_summary_bucket,
      key_path: classification_summary_s3_key,
      data_str: summary.to_json)
  end

  def classification_summary
    JSON.parse s3_client.retrieve(
      bucket: Rails.application.config.app_pkg_summary_bucket,
      key_path: classification_summary_s3_key)
  end

  def invalidate_activities!
    app = self.android_app
    happened_at_date = self.first_valid_date
    activities = Activity.where(happened_at: happened_at_date)

    # ensure these activities are from this app
    activities = activities.select do |a|
      a.weekly_batches.select { |b| b.owner == app }.present?
    end

    activities.each { |a| a.invalidate! }
  end
end
