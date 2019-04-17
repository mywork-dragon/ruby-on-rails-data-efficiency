class ContactExportService

  include Sidekiq::Worker

  sidekiq_options queue: :contacts_export, retry: true

  def start_export(publishers, filter)
    publishers.each do |publisher|
      ContactsExportWorker.perform_async(publisher, filter)
    end

    check_status
  end

  def check_status
    Sidekiq::Queue.new(:contacts_export).size
  end
end