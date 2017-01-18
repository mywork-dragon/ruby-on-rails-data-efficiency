class CreateAndroidAppRankings < ActiveRecord::Migration
  def change
    create_table :android_app_rankings do |t|
      t.integer :android_app_id
      t.integer :android_app_ranking_snapshot_id
      t.integer :rank
      t.timestamps null: false
    end

    add_index :android_app_rankings, [:android_app_id, :rank]
    add_index :android_app_rankings, [:android_app_ranking_snapshot_id, :android_app_id, :rank], name: 'index_android_ranking_snap_app_rank'
  end
end
