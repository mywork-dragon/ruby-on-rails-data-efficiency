class AddLookupContentToIpaSnapshots < ActiveRecord::Migration
  def change
    add_column :ipa_snapshots, :lookup_content, :text
  end
end
