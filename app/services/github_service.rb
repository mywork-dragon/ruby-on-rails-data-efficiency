class GithubService

  # Repo can be URL or user/repo
  def get_repo_data(repo)
    repos_api_url = 
      if repo.match(/\Ahttps?:\/\//)  # if it looks like a url
        repo.sub('github.com/', 'api.github.com/repos/')
      elsif repo.split('/').count == 2
        'https://api.github.com/repos/' + repo
      end

      if match_data = repos_api_url.match(/\Ahttps?/)
        protocol = match_data[0]
        host = 
      else
        raise 'Only HTTP and HTTPS supported'
      end


    @repo_html = Proxy.get(req: {:host => "www.google.com/search", protocol: protocol}, params: {'q' => q}, nokogiri: true)

    JSON.parse(@repo_html)
  end

  class << self
    def get_repo_data(repo)
      self.new.get_repo_data(repo)
    end
  end

end