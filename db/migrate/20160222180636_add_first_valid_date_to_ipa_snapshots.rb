class AddFirstValidDateToIpaSnapshots < ActiveRecord::Migration
  def change
    add_column :ipa_snapshots, :first_valid_date, :datetime, default: Time.now
  end
end
