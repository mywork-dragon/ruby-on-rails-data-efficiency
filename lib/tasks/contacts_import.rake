require '/varys/app/workers/contacts_import/contacts_import_worker'

namespace 'contacts' do

  desc 'Import the contacts from files in s3 into the varys db'
  task :import => [:environment] do
    ContactsImportWorker.perform('contacts', 6)
  end  
end