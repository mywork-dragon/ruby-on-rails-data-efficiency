class AddDefaultToEnabledAppStore < ActiveRecord::Migration
  def change
    change_column :app_stores, :enabled, :boolean, default: false
  end
end
