class AddIndexToInstallation < ActiveRecord::Migration
  def change
    remove_index :installations, :company_id
    remove_index :installations, :service_id
    # use composite index instead as we are always looking up by timestamp
    add_index :installations, [:company_id, :created_at]
    add_index :installations, [:service_id, :created_at]
    # sometimes we will prob also look up by status and date
    add_index :installations, [:status, :created_at]
  end
end
