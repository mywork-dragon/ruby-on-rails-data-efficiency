class GithubApi

  DEV_CLIENT_ID = ENV['GITHUB_DEV_CLIENT_ID'].to_s
  DEV_CLIENT_SECRET = ENV['GITHUB_DEV_CLIENT_SECRET'].to_s

  include HTTParty
  include ProxyParty

  base_uri 'https://api.github.com'
  format :json

  class UnrecognizedRepoUrl < RuntimeError
  end

  # Get branch meta information
  # @repo: 'Cocoapods/Specs'
  # @branch: 'master'
  def self.branch_info(repo, branch)
    path = File.join('/repos', repo, 'branches', branch)
    proxy_request do
      get(path, query: get_credentials)
    end
  end

  # Get repo meta information
  # @repo: 'Cocoapods/Specs'
  def self.repo_info(repo)
    path = File.join('/repos', repo)
    proxy_request do
      get(path, query: get_credentials)
    end
  end

  def self.repo_info_from_url(url)
    repo_info url_to_repo(url)
  end

  # Get tag informmation
  def self.tags(repo)
    path = File.join('/repos', repo, 'tags')
    proxy_request do
      get(path, query: get_credentials)
    end
  end

  # Get information on the author of the repo
  # nil if unknown
  def self.author_info(repo)
    info = repo_info(repo)

    if info['owner'] && info['owner']['url']
      ProxyRequest.get(info['owner']['url'], query: get_credentials)
    else
      nil
    end
  end

  def self.author_info_from_url(url)
    author_info url_to_repo(url)
  end
  
  # If directory, will return an array of the files straight from Github API
  # If a file, will return the file contents (if not base64, will return the Github object)
  def self.contents(repo, path)
    path = File.join('/repos', repo, 'contents', path)
    proxy_request do
      # have to operate directly on the body, not the HTTParty::Response object
      data = JSON.parse(get(path, query: get_credentials).body)
      
      if data.class == Array
        data
      elsif data['content'] && data['encoding'] == 'base64'
        Base64.decode64(data['content'])
      else
        data
      end
    end
  end

  # Check the rate limit of a specific set of credentials
  def self.rate_limit(client_id:, client_secret:)
    proxy_request do
      get('/rate_limit', query: {client_id: client_id, client_secret: client_secret})
    end
  end

  def self.check_limits
      GithubAccount.all.each do |acct|
        client_id = acct.client_id
        client_secret = acct.client_secret

        data = rate_limit(client_id: client_id, client_secret: client_secret)
        puts "Account #{acct.id} has #{data['resources']['core']['remaining']} / #{data['resources']['core']['limit']}"
      end

      nil
  end

  def self.url_to_repo(url)
    if url.match(/\Ahttps?:\/\//)  # if it looks like a url
      URI(url).path.split("/")[0..2].join("/").gsub('.git', '')
    else
      raise UnrecognizedRepoUrl, "Could not extract repo information from url: #{url}"
    end
  end

  def self.get_credentials

    if Rails.env.production?
      acct = GithubAccount.select(:id, :client_id, :client_secret).sample

      acct.last_used = DateTime.now
      begin
        acct.save
      rescue
        nil
      end

      client_id = acct.client_id
      client_secret = acct.client_secret
    else

      client_id = DEV_CLIENT_ID
      client_secret = DEV_CLIENT_SECRET
    end

    {
      client_id: client_id,
      client_secret: client_secret
    }
  end
  
end
