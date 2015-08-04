class RenameCopywrightToCopyrightOnIosEpfSnapshots < ActiveRecord::Migration
  def change
    rename :ios_epf_snapshots, :copywright, :copyright
  end
end
