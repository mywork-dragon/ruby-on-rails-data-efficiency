class ProxiedPageOpener

  class << self
    
    def open(url)
      
      # OpenURI patches Kernel.open
      Kernel.open(url, allow_redirections: :all, "User-Agent" => UserAgent.random_web)
    end
    
  end

end