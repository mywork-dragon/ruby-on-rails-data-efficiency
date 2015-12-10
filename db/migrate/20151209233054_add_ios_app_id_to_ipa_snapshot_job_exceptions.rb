class AddIosAppIdToIpaSnapshotJobExceptions < ActiveRecord::Migration
  def change
    add_column :ipa_snapshot_job_exceptions, :ios_app_id, :integer
  end
end
