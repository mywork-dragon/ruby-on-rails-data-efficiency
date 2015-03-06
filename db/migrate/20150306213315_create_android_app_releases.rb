class CreateAndroidAppReleases < ActiveRecord::Migration
  def change
    create_table :android_app_releases do |t|

      t.timestamps
    end
  end
end
