class AddIsRankingLabelToAndroidCategories < ActiveRecord::Migration
  def change
    add_column :android_app_categories, :is_ranking_label, :boolean, :default => false
  end
end
