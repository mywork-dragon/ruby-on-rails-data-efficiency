class DestroyAndroidAppReviewSnapshots < ActiveRecord::Migration
  def change
    drop_table :android_app_review_snapshots
  end
end
