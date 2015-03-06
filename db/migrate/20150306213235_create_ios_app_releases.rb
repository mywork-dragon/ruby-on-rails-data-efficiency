class CreateIosAppReleases < ActiveRecord::Migration
  def change
    create_table :ios_app_releases do |t|

      t.timestamps
    end
  end
end
