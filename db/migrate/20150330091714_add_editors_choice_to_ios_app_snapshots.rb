class AddEditorsChoiceToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :editors_choice, :boolean
  end
end
