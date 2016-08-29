class AppStoreInternationalCurrentSnapshotWorker
  include Sidekiq::Worker
  include AppStoreInternationalSnapshotModule
  
  sidekiq_options retry: 1, queue: :default

  def initialize
    @current_tables = true
  end
end
