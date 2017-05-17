class CreateSavedSearches < ActiveRecord::Migration
  def change
    create_table :saved_searches do |t|
      t.string :name, limit: 191
      t.belongs_to :user, index: true
      t.text :search_params
      t.timestamps null: false
    end
  end
end
