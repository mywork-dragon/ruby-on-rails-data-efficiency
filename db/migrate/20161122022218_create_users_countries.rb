class CreateUsersCountries < ActiveRecord::Migration
  def change
    create_table :users_countries do |t|
      t.integer :user_id
      t.string :country_code
      t.timestamps null: false
    end

    add_index :users_countries, [:user_id, :country_code], unique: true
    add_index :users_countries, :country_code
  end
end
