class RenameCopywrightToCopyrightOnIosEpfSnapshots < ActiveRecord::Migration
  def change
    rename_column :ios_app_epf_snapshots, :copywright, :copyright
  end
end
