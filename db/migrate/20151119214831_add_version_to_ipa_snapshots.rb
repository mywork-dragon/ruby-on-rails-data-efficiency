class AddVersionToIpaSnapshots < ActiveRecord::Migration
  def change
    add_column :ipa_snapshots, :version, :string
  end
end
