class FaviconService

  GOOGLE_DEFAULT_PATH = Rails.root.join('lib', 'globe.png')

  class << self

    # returns a favicon url
    # if try_backup is true, will check to see it's just the google default
    # and try a different methodology
    def get_favicon_from_url(url:, try_backup: true)
      url = ensure_scheme(url) # put http on the front
      host = URI.parse(url).host || ""
      host = host.gsub(/^www\./, '')
      favicon = "https://www.google.com/s2/favicons?domain=#{host}"

      return favicon if !try_backup || !is_google_default?(favicon_url: favicon)

      backup = get_backup(host: host)


      # use the original favicon if backup isn't good
      return favicon if backup.nil? || is_google_default?(favicon_url: backup)

      backup
    end

    # use google default by giving a non-existing domain
    def get_default_favicon
      "https://www.google.com/s2/favicons?domain=hellostephenisneat.edu"
    end

    def ensure_scheme(url, scheme: 'http')
      URI.parse(url).scheme.nil? ? "#{scheme}://#{url}" : url
    end

    # given a host, tries to make an http request to get the favicon.
    # Returns a url on success
    # Returns nil if unsuccessful
    def get_backup(host:)
      url = ensure_scheme(host)
      begin
        WWW::Favicon.new.find(url)
        # TODO: add backup check to make sure there's no SSL weirdness
      rescue
        nil
      end
    end

    def is_google_default?(favicon_url:)
      current_path = if /s2\/favicons/.match(favicon_url)
        favicon_url.split("=").last
      else
        favicon_url = ensure_scheme(favicon_url)
        URI.parse(favicon_url).host
      end

      current_path = File.join('/tmp', "#{current_path}.png")
      
      # turn off SSL strictness for favicon downloading
      File.open(current_path, 'wb') {|f| f << open(favicon_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read}

      default = Digest::MD5.file(GOOGLE_DEFAULT_PATH)
      current = Digest::MD5.file(current_path)

      default == current
    end

  end
end
