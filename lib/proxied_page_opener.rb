class ProxiedPageOpener

  class << self
    
    def open(url)
      
      #get the non-busy server that was used last and is active
      proxy
      
      #OpenURI patches Kernel.open
      Kernel.open(url, allow_redirections: :all, "User-Agent" => UserAgent.random_web, proxy: proxy.url_and_port)
      
      #update the last used date of the server
    end
    
  end

end