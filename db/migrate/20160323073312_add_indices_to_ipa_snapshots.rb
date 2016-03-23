class AddIndicesToIpaSnapshots < ActiveRecord::Migration
  def change
    add_index :ipa_snapshots, [:ios_app_id, :good_as_of_date]
    add_index :ipa_snapshots, [:success, :scan_status]
  end
end
