class GithubService

  # Repo can be URL or user/repo
  def repo_to_url(repo)
    if repo.match(/\Ahttps?:\/\//)  # if it looks like a url
      repo.sub('github.com/', 'api.github.com/repos/')
    elsif repo.split('/').count == 2
      'https://api.github.com/repos/' + repo
    end
  end

  # Repo can be URL or user/repo
  def get_repo_data(repo)
    repos_api_url = repo_to_url(repo)

    # putting it an ivar in case want to do other options to it in the future
    @repo_html = Proxy.get_url(repos_api_url) 

    JSON.parse(@repo_html)
  end

  # Repo can be URL or user/repo
  # If directory, will return an array of the files straight from Github API
  # If a file, will return the file contents (if not base64, will return the Github object)
  def get_contents(repo, path)

    repos_api_url = repo_to_url(repo)

    if !path.nil?
      repos_api_url = File.join(repos_api_url, 'contents', path)
    end

    data = Proxy.get_url(repos_api_url)

    raise data if data.class == String # TODO: add validation to make sure github didn't respond poorly

    data = JSON.parse(data.body)

    return data if data.class == Array

    if data["content"] && data["encoding"] == "base64"
      Base64.decode64(data["content"])
    else
      data # this handles JSON error responses
    end

  end
  class << self
    def get_repo_data(repo)
      self.new.get_repo_data(repo)
    end

    def get_contents(repo, path=nil)
      self.new.get_contents(repo, path)
    end

  end

end