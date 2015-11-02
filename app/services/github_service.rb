class GithubService

  # Repo can be URL or user/repo
  def get_repo_data(repo)
    repos_api_url = 
      if repo.match(/\Ahttps?:\/\//)  # if it looks like a url
        repo.sub('github.com/', 'api.github.com/repos/')
      elsif repo.split('/').count == 2
        'https://api.github.com/repos/' + repo
      end

    @repo_html = Proxy.get(req: repos_api_url)

    JSON.parse(@repo_html)
  end

  class << self
    def get_repo_data(repo)
      self.new.get_repo_data(repo)
    end
  end

end