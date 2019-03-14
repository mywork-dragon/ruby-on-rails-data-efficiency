class ContactExportService

  include Sidekiq::Worker

  sidekiq_options queue: :contacts_export, retry: true

  class << self
    def start_export(publisher_ids_list, platform, filter)
      publisher_ids_list.each do |publisher_id|
        ContactsExportWorker.perform_async(publisher_id, platform, filter)
      end

      check_status
    end

    def check_status
      Sidekiq::Queue.new(:contacts_export).size
    end
  end
end