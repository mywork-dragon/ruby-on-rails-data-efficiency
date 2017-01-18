class CreateAndroidAppRankingSnapshots < ActiveRecord::Migration
  def change
    create_table :android_app_ranking_snapshots do |t|
      t.integer :kind
      t.boolean :is_valid, default: false
      t.timestamps null: false
    end
  end
end
