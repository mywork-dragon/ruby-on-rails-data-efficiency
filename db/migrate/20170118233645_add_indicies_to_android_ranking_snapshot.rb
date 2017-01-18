class AddIndiciesToAndroidRankingSnapshot < ActiveRecord::Migration
  def change
    add_index :android_app_ranking_snapshots, [:kind, :is_valid]
    add_index :android_app_ranking_snapshots, :is_valid
  end
end
