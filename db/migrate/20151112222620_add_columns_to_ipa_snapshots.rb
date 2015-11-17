class AddColumnsToIpaSnapshots < ActiveRecord::Migration
  def change
    add_column :ipa_snapshots, :status, :integer
    add_column :ipa_snapshots, :success, :boolean
    add_column :ipa_snapshots, :ipa_snapshot_job_id, :integer

    add_index :ipa_snapshots, [:ipa_snapshot_job_id, :ios_app_id], unique: true
  end
end
