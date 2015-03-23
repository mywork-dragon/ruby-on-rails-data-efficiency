class ChangeWorkerIdentifierInMTurkWorkers < ActiveRecord::Migration
  def change
    change_column :m_turk_workers, :worker_identifier, :string
  end
end
