Whois::Server::SocketHandler.class_eval do
  
  alias_method :old_execute, :execute
  
  def execute(query, *args)
    proxy = Tor.next_proxy
    proxy.last_used = DateTime.now
    proxy.save
    
    TCPSocket::socks_server = proxy.private_ip
    TCPSocket::socks_port = 9050

    old_execute(query, *args)
  end
  
end