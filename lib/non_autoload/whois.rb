module Whois
  class Client

    def blah
      puts "whassup"
    end

  end
  
  class Server
    
    class SocketHandler
      
      def execute(query, *args)
        puts "EXECUTION!!!"
      
        # super
      end
      
    end
    
  end
end