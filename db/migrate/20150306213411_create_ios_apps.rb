class CreateIosApps < ActiveRecord::Migration
  def change
    create_table :ios_apps do |t|

      t.timestamps
    end
  end
end
