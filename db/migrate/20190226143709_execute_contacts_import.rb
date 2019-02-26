class ExecuteContactsImport < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        ContactsImport.generate()
      end
      dir.down do
        # Do nothing, to avoid the execution of the script on rollback
      end
    end
  end
end
