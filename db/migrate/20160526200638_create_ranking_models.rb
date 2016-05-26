class CreateRankingModels < ActiveRecord::Migration
  def change
    create_table :ios_app_ranking_snapshots do |t|
      t.integer :kind
      t.boolean :is_valid, default: false
    end

    add_index :ios_app_ranking_snapshots, [:kind, :is_valid]
    add_index :ios_app_ranking_snapshots, :is_valid
  
    create_table :ios_app_rankings do |t|
      t.integer :ios_app_id
      t.integer :ios_app_ranking_snapshot_id
      t.integer :rank
    end

    add_index :ios_app_rankings, [:ios_app_ranking_snapshot_id, :ios_app_id, :rank], name: 'index_on_ios_app_ranking_snapshot_id_and_ios_app_id_and_rank'
    add_index :ios_app_rankings, [:ios_app_id, :rank]
    add_index :ios_app_rankings, :rank
  end
end 
