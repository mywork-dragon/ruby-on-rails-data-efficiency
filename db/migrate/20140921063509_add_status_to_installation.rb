class AddStatusToInstallation < ActiveRecord::Migration
  def change
    add_column :installations, :status, :integer
  end
end