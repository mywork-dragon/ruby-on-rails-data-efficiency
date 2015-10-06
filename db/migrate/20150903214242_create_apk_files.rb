class CreateApkFiles < ActiveRecord::Migration
  def change
    create_table :apk_files do |t|

      t.timestamps
    end
  end
end
