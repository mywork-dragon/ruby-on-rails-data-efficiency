class AddGithubRepoIdentifierToIosSdks < ActiveRecord::Migration
  def change
    add_column :ios_sdks, :github_repo_identifier, :integer
    add_index :ios_sdks, :github_repo_identifier, unique: true
  end
end
