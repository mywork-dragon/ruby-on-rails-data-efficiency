class ChangeKindOnIosAppCategoriesSnapshotsToInteger < ActiveRecord::Migration
  def change
    change_column :ios_app_categories_snapshots, :kind, :integer
  end
end
