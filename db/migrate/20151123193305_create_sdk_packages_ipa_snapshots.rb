class CreateSdkPackagesIpaSnapshots < ActiveRecord::Migration
  def change
    create_table :sdk_packages_ipa_snapshots do |t|

      t.timestamps
    end
  end
end
