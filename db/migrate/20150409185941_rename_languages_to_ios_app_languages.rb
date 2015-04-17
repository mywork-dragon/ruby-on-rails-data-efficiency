class RenameLanguagesToIosAppLanguages < ActiveRecord::Migration
  def change
    rename_table :languages, :ios_app_languages
  end
end
