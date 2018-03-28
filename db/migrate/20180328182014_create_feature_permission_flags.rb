class CreateFeaturePermissionFlags < ActiveRecord::Migration
  def change
    create_table :feature_permission_flags do |t|
      t.string :name, null: false
      t.boolean :enabled, null: false

      t.timestamps null: false
    end
  end
end
