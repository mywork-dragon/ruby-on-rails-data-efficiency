class GithubService

  # Repo can be URL or user/repo
  def repo_to_url(repo)
    if repo.match(/\Ahttps?:\/\//)  # if it looks like a url
      repo.sub('github.com/', 'api.github.com/repos/')
    elsif repo.split('/').count == 2
      'https://api.github.com/repos/' + repo
    end
  end

  # Wrapper around Proxy for making a request and rotate github credentials to avoid rate limiting
  # @body Boolean flag on whether or not to return the body (defaults to true)
  # @returns either the body or a CurbFu::Response::Base object
  def make_request(url, body = true)

    response = if Rails.env.production?
      acct = GithubAccount.transaction do
        a = GithubAccount.lock.order(last_used: :asc).first
        a.last_used = DateTime.now
        a.save
        a
      end

      Proxy.get_from_url(url, params: {'client_id' => acct.client_id, 'client_secret' => acct.client_secret})
    else
      # hard code account for dev
      Proxy.get_from_url(url, params: {'client_id' => '47966b7ae432cb33ee4b', 'client_secret' => 'bf4f68f86c48641196e9b9e9326ba821cf6355d6'})
    end

    if body
      response.body
    else
      response
    end
  end

  # Repo can be URL or user/repo
  # Returns a JSON object of the repo's metadata
  def get_repo_data(repo)
    repos_api_url = repo_to_url(repo)

    # putting it an ivar in case want to do other options to it in the future
    @repo_html = make_request(repos_api_url)
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

    data = JSON.parse(make_request(repos_api_url))

    return data if data.class == Array

    if data["content"] && data["encoding"] == "base64"
      Base64.decode64(data["content"])
    else
      data # this handles JSON error responses
    end

  end

  def get_branch_data(repo, branch)
    repos_api_url = repo_to_url(repo)

    url = "#{repos_api_url}/branches/#{branch}"
    JSON.parse(make_request(url))
  end

  class << self
    def get_repo_data(repo)
      self.new.get_repo_data(repo)
    end

    def get_contents(repo, path=nil)
      self.new.get_contents(repo, path)
    end

    # Gets the branch metadata for the specified branch. Will use branch 'master' if not supplied
    # @returns the Github API response object as JSON
    def get_branch_data(repo, branch='master')
      self.new.get_branch_data(repo, branch)
    end
  end

end