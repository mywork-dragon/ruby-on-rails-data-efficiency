require '/varys/app/workers/contacts_import/contacts_import_worker'

namespace 'contacts' do

  desc 'Import the contacts from files in s3 into the varys db'
  task :import => [:environment] do
    # This number (18072), comes from the amount of files in 
    # https://s3.console.aws.amazon.com/s3/buckets/findemails/employees_data/?region=us-east-1
    ContactsImportWorker.perform('contacts', 18072)
  end  
end