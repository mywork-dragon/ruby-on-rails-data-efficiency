class AddBundleVersionToIpaSnapshots < ActiveRecord::Migration
  def change
    add_column :ipa_snapshots, :bundle_version, :string
  end
end
