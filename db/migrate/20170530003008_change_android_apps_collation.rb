class ChangeAndroidAppsCollation < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE android_apps CONVERT TO CHARACTER SET utf8mb4 collate utf8mb4_bin;
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE android_apps CONVERT TO CHARACTER SET utf8mb4 collate utf8mb4_unicode_ci;
        SQL
      end
    end

  end
end
