class CreateSdkDlls < ActiveRecord::Migration
  def change
    create_table :sdk_dlls do |t|
      t.string :name

      t.timestamps
    end
    add_index :sdk_dlls, :name
  end
end
