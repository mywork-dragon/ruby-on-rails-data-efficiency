class AddAppStoreIdToIpaSnapshots < ActiveRecord::Migration
  def change
    add_column :ipa_snapshots, :app_store_id, :integer
    add_index :ipa_snapshots, :app_store_id
  end
end
