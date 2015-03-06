class CreateAndroidAppReviewSnapshots < ActiveRecord::Migration
  def change
    create_table :android_app_review_snapshots do |t|

      t.timestamps
    end
  end
end
