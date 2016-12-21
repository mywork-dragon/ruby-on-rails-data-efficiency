class IosPackageReclassificationWorker

  include Sidekiq::Worker

  sidekiq_options :retry => false, queue: :ios_reclassification
  
  # assumes that package has been updated
  def perform(ipa_snapshot_id, previous_sdk_id = nil, new_sdk_id = nil)

    # remove attribution if not linked through any other package
    if previous_sdk_id
      snapshot = IpaSnapshot.find(ipa_snapshot_id)

      unless snapshot.sdk_packages.where(ios_sdk_id: previous_sdk_id).any?
        snapshot.ios_sdks_ipa_snapshots.where(ios_sdk_id: previous_sdk_id, method: IosSdksIpaSnapshot.methods[:strings]).delete_all
      end
    end

    # add attribution to new sdk
    if new_sdk_id
      IosSdksIpaSnapshot.find_or_create_by!(ipa_snapshot_id: ipa_snapshot_id, ios_sdk_id: new_sdk_id, method: IosSdksIpaSnapshot.methods[:strings]) if new_sdk_id.present?
    end

  rescue => e

    IosClassificationException.create!({
      ipa_snapshot_id: ipa_snapshot_id,
      error: e.message,
      backtrace: e.backtrace
    })

    raise e
  
  end

end

