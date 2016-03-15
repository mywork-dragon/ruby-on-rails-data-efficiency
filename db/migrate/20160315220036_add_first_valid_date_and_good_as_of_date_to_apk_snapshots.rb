class AddFirstValidDateAndGoodAsOfDateToApkSnapshots < ActiveRecord::Migration
  def change
    add_column :apk_snapshots, :first_valid_date, :datetime
    add_column :apk_snapshots, :good_as_of_date, :datetime
  end
end
