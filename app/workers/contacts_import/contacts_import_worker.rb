require_relative './contacts_import'

class ContactsImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :contacts_upload, retry: true

  S3_BUCKET = 'findemails'
  S3_FOLDER = 'employees_data'
  MAX_FILE_SIZE = 600000

  class << self
    def perform(filename_prefix='contacts', number_of_files=1)
      file_names = (1..number_of_files).map { |n| "#{filename_prefix}#{n}.csv" }
      file_names.each { |file_name| execute_worker(file_name) }
    end

    def execute_worker(file_name)
      file_size = MightyAws::S3.new.content_length(bucket: S3_BUCKET, key_path: S3_FOLDER + '/' + file_name)
      if file_size <= MAX_FILE_SIZE
        file_content = MightyAws::S3.new.retrieve( bucket: S3_BUCKET, key_path: S3_FOLDER + '/' + file_name, ungzip: false )
        ContactsImport.perform_async(file_content) if file_content
      else
        p "Couldn't download files bigger than #{MAX_FILE_SIZE}, current size file #{file_size}"
      end
    ensure
      File.delete(file_name) if File.exist?(file_name)
    end
  end

end