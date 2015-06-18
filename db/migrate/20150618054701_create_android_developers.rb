class CreateAndroidDevelopers < ActiveRecord::Migration
  def change
    create_table :android_developers do |t|
      t.string :name

      t.timestamps
    end
    add_index :android_developers, :name
  end
end
