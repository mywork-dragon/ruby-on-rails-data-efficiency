require '/varys/app/workers/contacts_import/contacts_import_worker'

namespace 'contacts' do

  desc 'Import the contacts from files in s3 into the varys db'
  task :import, [:number_files, :file_prefix, :starting_file] => [:environment] do |t, args|
    raise ArgumentError, 'File prefix is needed' unless args.file_prefix
    raise ArgumentError, 'Number of files is needed' unless args.number_files
    ContactsImportWorker.perform( args.number_files.to_i, args.file_prefix.to_s, args.starting_file.to_i)
  end
end
