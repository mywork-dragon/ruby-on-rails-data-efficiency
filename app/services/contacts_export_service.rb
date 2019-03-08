class ContactExportService
  class << self
    def start_export(publisher_ids_list)
      # TODO create the job and return the job_id
      ContactsExportWorker.perform_async(publisher_id)
      # TODO return job id
    end

    def check_status(job_id:)

    end
  end
end