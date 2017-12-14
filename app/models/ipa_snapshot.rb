class IpaSnapshot < ActiveRecord::Base

	has_many :class_dumps
  has_many :ipa_snapshot_exceptions
  has_many :ios_classification_exceptions

	belongs_to :ios_app
  belongs_to :ipa_snapshot_job

	has_many :ios_sdks_ipa_snapshots
	has_many :ios_sdks, through: :ios_sdks_ipa_snapshots

  has_many :sdk_packages_ipa_snapshots
  has_many :sdk_packages, through: :sdk_packages_ipa_snapshots

  has_many :ipa_snapshots_sdk_dlls
  has_many :sdk_dlls, through: :ipa_snapshots_sdk_dlls

  has_many :ipa_snapshots_sdk_js_tags
  has_many :sdk_js_tags, through: :ipa_snapshots_sdk_js_tags

  belongs_to :app_store

  enum download_status: [:starting, :retrying, :cleaning, :complete, :unchanged]
  enum scan_status: [:scanning, :scanned, :failed, :arch_issue, :invalidated]

  before_create :set_dates

  def set_dates
    x = Time.now
    self.good_as_of_date = x
    self.first_valid_date = x
  end

  def invalidate
    self.update(scan_status: :invalidated)

    invalidate_activities if self.ios_app_id
    IosApp.find(self.ios_app_id).update_newest_ipa_snapshot if self.ios_app_id
  end

  def invalidate_activities
    app = self.ios_app
    happened_at_date = self.first_valid_date
    activities = Activity.where(happened_at: happened_at_date)

    # ensure these activities are from this iOS app
    activities = activities.select do |a|
      a.weekly_batches.select { |b| b.owner == app }.present?
    end

    activities.each { |a| a.invalidate! }
  end
  
end
