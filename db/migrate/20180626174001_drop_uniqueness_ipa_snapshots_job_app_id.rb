class DropUniquenessIpaSnapshotsJobAppId < ActiveRecord::Migration
  def change
    add_index :ipa_snapshots, [:ipa_snapshot_job_id, :ios_app_id], name: 'index_ipa_snaps_job_id_app_id'
    remove_index :ipa_snapshots, name: 'index_ipa_snapshots_on_ipa_snapshot_job_id_and_ios_app_id'
  end
end
