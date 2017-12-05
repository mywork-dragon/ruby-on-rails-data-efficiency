# Base used for export workers.
class ExportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :application_export, retry: false

  def export_store
    Redis.new(url: ENV['MS_FEEDS_REDIS_DSN']) 
  end

end
