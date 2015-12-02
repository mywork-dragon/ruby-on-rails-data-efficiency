class GithubService

  # Repo can be URL or user/repo
  def repo_to_url(repo)
    if repo.match(/\Ahttps?:\/\//)  # if it looks like a url
      new_path = URI(repo).path.split("/")[0..2].join("/").gsub('.git', '')
      File.join('https://api.github.com/repos/', new_path)
    elsif repo.split('/').count == 2
      'https://api.github.com/repos/' + repo
    end
  end

  # Wrapper around Proxy for making a request and rotate github credentials to avoid rate limiting
  # @body Boolean flag on whether or not to return the body (defaults to true)
  # @returns either the body or a CurbFu::Response::Base object

  def get_credentials
    acct = GithubAccount.select(:id, :client_id, :client_secret).sample

    acct.last_used = DateTime.now
    begin
      acct.save
    rescue
      nil
    end
    
    # acct = GithubAccount.transaction do
    #   a = GithubAccount.lock.order(last_used: :asc).first
    #   a.last_used = DateTime.now
    #   a.save
    #   a
    # end

    {
      client_id: acct.client_id,
      client_secret: acct.client_secret
    }
  end

  def make_request(url, body = true, headers: {}, params: {})

    if Rails.env.production?
      acct = get_credentials
      client_id = acct[:client_id]
      client_secret = acct[:client_secret]
    else
      # hard code account for dev
      client_id = '47966b7ae432cb33ee4b'
      client_secret = 'bf4f68f86c48641196e9b9e9326ba821cf6355d6'
    end

    response = Proxy.get_from_url(url, headers: headers, params: {'client_id' => client_id, 'client_secret' => client_secret}.merge(params))

    if body
      response.body
    else
      response
    end
  end

  # Repo can be URL or user/repo
  # Returns a JSON object of the repo's metadata
  # @author Jason Lew
  # @return The repo info in a Hash
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

  # Gets the tags on a repo. Repo can be either user/repo or a url.
  # Returns a JSON object 
  def get_tags(repo)
    repos_api_url = repo_to_url(repo)
    url = File.join(repos_api_url, "tags")

    JSON.parse(make_request(url, true))
  end

  class << self

    def get_author_info(repo)
      service = self.new
      repo_data = service.get_repo_data(repo)

      if repo_data['owner'] && repo_data['owner']['url']
        JSON.parse(service.make_request(repo_data['owner']['url']))
      else
        nil
      end

    end

    def get_repo_data(repo)
      self.new.get_repo_data(repo)
    end

    def get_tags(repo)
      self.new.get_tags(repo)
    end

    def get_contents(repo, path=nil)
      self.new.get_contents(repo, path)
    end

    def get_credentials
      self.new.get_credentials
    end

    # Gets the branch metadata for the specified branch. Will use branch 'master' if not supplied
    # @returns the Github API response object as JSON
    def get_branch_data(repo, branch='master')
      self.new.get_branch_data(repo, branch)
    end

    # Gets all the github accounts and make sure they are valid (rate limit is 5000 on core)
    def validate_tokens
      GithubAccount.all.each do |acct|
        params = {
          'client_id' => acct.client_id,
          'client_secret' => acct.client_secret
        }

        body = JSON.parse(Proxy.get_body_from_url('https://api.github.com/rate_limit',params: params))



        if body["resources"]["core"]["limit"] != 5000
          puts "Account #{acct.username} does not have a 5000 limit"
        end
      end
    end
  end

end