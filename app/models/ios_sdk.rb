class IosSdk < ActiveRecord::Base

	belongs_to :sdk_company
  belongs_to :ios_sdk_source_group

  has_many :sdk_packages
  has_many :cocoapod_metrics

	has_many :ios_sdks_ipa_snapshots
  has_many :ipa_snapshots, through: :ios_sdks_ipa_snapshots

  has_many :cocoapods
  

  has_many :ios_sdk_source_matches, foreign_key: :source_sdk_id
  has_many :source_matches, through: :ios_sdk_source_matches, source: :match_sdk

  enum source: [:cocoapods, :package_lookup]

  def get_current_apps(count_only: false)

    if count_only
      self.ipa_snapshots.select('ios_app_id, max(good_as_of_date) as good_as_of_date').where(scan_status: 1).group(:ios_app_id).length
    else
      # TODO: revisit this to make it 1 query
      IosApp.where(id: self.ipa_snapshots.select('ios_app_id, max(good_as_of_date) as good_as_of_date').where(scan_status: 1).group(:ios_app_id).pluck(:ios_app_id))
    end
  end

end
