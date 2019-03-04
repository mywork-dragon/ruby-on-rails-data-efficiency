require_relative './contacts_import'

class ContactsImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :sidekiq_batcher

  S3_BUCKET = 'findemails'
  S3_FOLDER = 'employees_data'

  class << self
    def perform(filename_prefix='contacts', number_of_files=1)
      file_names = (1..number_of_files).map { |n| "#{filename_prefix}#{n}.csv" }
      p file_names
      file_names.each do |file_name|
        execute_worker(file_name)
      end
    end

    def execute_worker(file_name)
      file_content = MightyAws::S3.new.retrieve( bucket: S3_BUCKET, key_path: S3_FOLDER + '/' + file_name, ungzip: false )
      unless file_content.nil?
        ContactsImport.perform_async(file_content)
      end
    ensure
      File.delete(file_name) if File.exist?(file_name)
    end

  end

end