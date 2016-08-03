class AddInternationalEnabledToIpaSnapshotJob < ActiveRecord::Migration
  def change
    add_column :ipa_snapshot_jobs, :international_enabled, :boolean, default: false
  end
end
