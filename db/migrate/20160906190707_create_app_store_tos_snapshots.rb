class CreateAppStoreTosSnapshots < ActiveRecord::Migration
  def change
    create_table :app_store_tos_snapshots do |t|
      t.integer :app_store_id
      t.date :last_updated_date
      t.datetime :good_as_of_date
      t.timestamps null: false
    end

    add_index :app_store_tos_snapshots, [:app_store_id, :last_updated_date], name: 'index_app_store_tos_store_id_updated_date'
    add_index :app_store_tos_snapshots, :last_updated_date
    add_index :app_store_tos_snapshots, :good_as_of_date
  end
end
