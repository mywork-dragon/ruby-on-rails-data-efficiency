class RemoveDefaultGoodAsOfDateFromIpaSnapshots < ActiveRecord::Migration
  def change
    change_column_default :ipa_snapshots, :good_as_of_date, nil
  end
end
