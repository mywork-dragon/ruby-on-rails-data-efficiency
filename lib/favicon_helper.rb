class FaviconHelper

  class << self
  
    def has_os_favicon?(favicon_url)

      return nil if favicon_url.nil?

      known_os_favicons = %w(
        github
        bitbucket
        sourceforge
        alamofire
        afnetworking
      )
      favicon_url.match(/#{known_os_favicons.join('|')}/) ? true : false
    end

  end

end