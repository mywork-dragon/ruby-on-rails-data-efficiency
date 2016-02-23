class ChangeDefaultFirstValidDateIpaSnapshots < ActiveRecord::Migration
  def change
    change_column_default :ipa_snapshots, :first_valid_date, nil
  end
end
