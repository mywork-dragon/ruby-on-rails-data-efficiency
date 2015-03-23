class RenameWorkerIdentifierInMTurkWorkers < ActiveRecord::Migration
  def change
    rename_column :m_turk_workers, :worker_identifier, :aws_identifier
  end
end
