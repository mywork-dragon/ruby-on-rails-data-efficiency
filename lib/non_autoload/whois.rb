Whois::Server::SocketHandler.class_eval do
  
  alias_method :old_execute, :execute
  
  def execute(query, *args)
    
    if Rails.env.production?
      proxy = Tor.next_proxy
      proxy.last_used = DateTime.now
      ip = proxy.private_ip
      proxy.save
    else
      ip = '127.0.0.1'
    end
      
    
    
    
    TCPSocket::socks_server = ip
    TCPSocket::socks_port = 9050

    old_execute(query, *args)
  end
  
end