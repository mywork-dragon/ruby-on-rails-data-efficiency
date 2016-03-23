class AddGoodAsOfDateIndexToIpaSnapshots < ActiveRecord::Migration
  def change
    add_index :ipa_snapshots, :good_as_of_date
  end
end
