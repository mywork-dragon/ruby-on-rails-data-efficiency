require '/varys/app/workers/contacts_import/contacts_import_worker'

namespace 'contacts' do

  desc 'Import the contacts from files in s3 into the varys db'
  task :import, [:file_prefix, :number_files] => [:environment] do |t, args|
    raise ArgumentError, 'File prefix is needed' if args.file_prefix.nil?
    raise ArgumentError, 'Number of files is needed' if args.number_files.nil?
    ContactsImportWorker.perform(args.file_prefix.to_s, args.number_files.to_i)
  end  
end