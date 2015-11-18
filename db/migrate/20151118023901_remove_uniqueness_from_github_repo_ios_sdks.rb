class RemoveUniquenessFromGithubRepoIosSdks < ActiveRecord::Migration
  def change
    remove_index :ios_sdks, name: 'index_ios_sdks_on_github_repo_identifier'
    add_index :ios_sdks, :github_repo_identifier
  end
end
