class CreateAppStores < ActiveRecord::Migration
  def change
    create_table :app_stores do |t|
      t.string :country_code

      t.timestamps
    end
    add_index :app_stores, :country_code
  end
end
