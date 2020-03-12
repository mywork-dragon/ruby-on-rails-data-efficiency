class RemoveGooglePlusLikesFromAndroidAppSnapshot < ActiveRecord::Migration
  def change
    remove_column :android_app_snapshots, :google_plus_likes, :integer
  end
end
