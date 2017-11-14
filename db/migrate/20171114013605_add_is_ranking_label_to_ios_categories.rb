class AddIsRankingLabelToIosCategories < ActiveRecord::Migration
  def change
    add_column :ios_app_categories, :is_ranking_label, :boolean, :default => false
  end
end
