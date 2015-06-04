Whois::Server::SocketHandler.class_eval do
  
  alias_method :old_execute, :execute
  
  def execute(query, *args)
    TCPSocket::socks_server = "127.0.0.1"
    TCPSocket::socks_port = 9050

    old_execute(query, *args)
  end
  
end