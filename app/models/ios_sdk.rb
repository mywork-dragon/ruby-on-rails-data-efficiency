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

    # get all the successful snapshots that have the sdk
    snaps = IpaSnapshot.find(IosSdksIpaSnapshot.where(ios_sdk_id: self.id).map {|row| row.ipa_snapshot_id})

    # get the latest snapshot for each app that found
    app_to_snap = snaps.reduce({}) do |memo, snapshot|
      current_value = memo[snapshot.ios_app_id]

      if !snapshot.scanned? # WOAHHH
        nil # do nothing. we don't count this result
      elsif current_value.present? # store only the most recent one

        if current_value.good_as_of_date == snapshot.good_as_of_date
          memo[snapshot.ios_app_id] = snapshot if snapshot.id > current_value.id
        else
          memo[snapshot.ios_app_id] = snapshot if snapshot.good_as_of_date > current_value.good_as_of_date
        end
      else
        memo[snapshot.ios_app_id] = snapshot
      end

      memo
    end

    # only keep those where the snapshot is the app's last snapshot
    app_to_snap.select! do |ios_app_id, snapshot|
      last_snap = IosApp.find(ios_app_id).get_last_ipa_snapshot(scan_success: true)
      last_snap.id == snapshot.id ? true : false
    end

    count_only ? app_to_snap.keys.length : IosApp.find(app_to_snap.keys)
  end

end
