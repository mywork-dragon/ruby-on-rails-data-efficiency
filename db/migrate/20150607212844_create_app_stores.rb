class CreateAppStores < ActiveRecord::Migration
  def change
    create_table :app_stores do |t|
      t.string :name

      t.timestamps
    end
    add_index :app_stores, :name
  end
end
