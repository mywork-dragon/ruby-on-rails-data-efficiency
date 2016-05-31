class AddTimestampsToRankingModels < ActiveRecord::Migration
  def change
    add_column(:ios_app_ranking_snapshots, :created_at, :datetime)
    add_column(:ios_app_ranking_snapshots, :updated_at, :datetime)

    add_column(:ios_app_rankings, :created_at, :datetime)
    add_column(:ios_app_rankings, :updated_at, :datetime)
  end
end
