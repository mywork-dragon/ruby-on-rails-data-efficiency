class CreateAppleDocs < ActiveRecord::Migration
  def change
    create_table :apple_docs do |t|
    	t.string :name

      t.timestamps
    end
    add_index :apple_docs, :name
  end
end
