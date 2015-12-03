class AddGoodAsOfDateToIpaSnapshots < ActiveRecord::Migration
  def change
    add_column :ipa_snapshots, :good_as_of_date, :datetime, default: Time.now
  end
end
