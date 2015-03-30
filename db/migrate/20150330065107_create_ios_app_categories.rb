class CreateIosAppCategories < ActiveRecord::Migration
  def change
    create_table :ios_app_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
