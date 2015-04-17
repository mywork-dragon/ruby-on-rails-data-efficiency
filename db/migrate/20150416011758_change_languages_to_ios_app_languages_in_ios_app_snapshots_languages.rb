class ChangeLanguagesToIosAppLanguagesInIosAppSnapshotsLanguages < ActiveRecord::Migration
  def change
    rename_column :ios_app_snapshots_languages, :language_id, :ios_app_language_id
  end
end
