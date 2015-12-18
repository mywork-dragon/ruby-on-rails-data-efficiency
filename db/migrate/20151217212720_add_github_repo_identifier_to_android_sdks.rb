class AddGithubRepoIdentifierToAndroidSdks < ActiveRecord::Migration
  def change
    add_column :android_sdks, :github_repo_identifier, :integer
    add_index :android_sdks, :github_repo_identifier, unique: true
  end
end
