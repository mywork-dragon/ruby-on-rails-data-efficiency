class Tor

  class << self
    
    def open(url)
      
      #get the non-busy server that was used last and is active
      proxy = Proxy..order("created_at desc").limit(1).first
      
      #OpenURI patches Kernel.open
      Kernel.open(url, allow_redirections: :all, "User-Agent" => UserAgent.random_web, proxy: proxy.url_and_port)
      
      #update the last used date of the server
    end
    
    def next_proxy
      
    end
    
  end

end