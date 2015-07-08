require 'net/protocol'
require 'uri'

module Net

  class HTTP < Protocol

    # The DNS host name or IP address to connect to.
    attr_reader :address

    # The port number to connect to.
    attr_reader :port

    # The local host used to estabilish the connection.
    attr_accessor :local_host

    # The local port used to estabilish the connection.
    attr_accessor :local_port

    attr_writer :proxy_from_env
    attr_writer :proxy_address
    attr_writer :proxy_port
    attr_writer :proxy_user
    attr_writer :proxy_pass

    # Number of seconds to wait for the connection to open. Any number
    # may be used, including Floats for fractional seconds. If the HTTP
    # object cannot open a connection in this many seconds, it raises a
    # Net::OpenTimeout exception. The default value is +nil+.
    attr_accessor :open_timeout

    # Number of seconds to wait for one block to be read (via one read(2)
    # call). Any number may be used, including Floats for fractional
    # seconds. If the HTTP object cannot read data in this many seconds,
    # it raises a Net::ReadTimeout exception. The default value is 60 seconds.
    attr_reader :read_timeout


    # Seconds to reuse the connection of the previous request.
    # If the idle time is less than this Keep-Alive Timeout,
    # Net::HTTP reuses the TCP/IP socket used by the previous communication.
    # The default value is 2 seconds.
    attr_accessor :keep_alive_timeout

    # Returns true if the HTTP session has been started.
    def started?
      @started
    end

    alias active? started?   #:nodoc: obsolete

    attr_accessor :close_on_empty_response


    SSL_IVNAMES = [
      :@ca_file,
      :@ca_path,
      :@cert,
      :@cert_store,
      :@ciphers,
      :@key,
      :@ssl_timeout,
      :@ssl_version,
      :@verify_callback,
      :@verify_depth,
      :@verify_mode,
    ]
    SSL_ATTRIBUTES = [
      :ca_file,
      :ca_path,
      :cert,
      :cert_store,
      :ciphers,
      :key,
      :ssl_timeout,
      :ssl_version,
      :verify_callback,
      :verify_depth,
      :verify_mode,
    ]

    # Sets path of a CA certification file in PEM format.
    #
    # The file can contain several CA certificates.
    attr_accessor :ca_file

    # Sets path of a CA certification directory containing certifications in
    # PEM format.
    attr_accessor :ca_path

    # Sets an OpenSSL::X509::Certificate object as client certificate.
    # (This method is appeared in Michal Rokos's OpenSSL extension).
    attr_accessor :cert

    # Sets the X509::Store to verify peer certificate.
    attr_accessor :cert_store

    # Sets the available ciphers.  See OpenSSL::SSL::SSLContext#ciphers=
    attr_accessor :ciphers

    # Sets an OpenSSL::PKey::RSA or OpenSSL::PKey::DSA object.
    # (This method is appeared in Michal Rokos's OpenSSL extension.)
    attr_accessor :key

    # Sets the SSL timeout seconds.
    attr_accessor :ssl_timeout

    # Sets the SSL version.  See OpenSSL::SSL::SSLContext#ssl_version=
    attr_accessor :ssl_version

    # Sets the verify callback for the server certification verification.
    attr_accessor :verify_callback

    # Sets the maximum depth for the certificate chain verification.
    attr_accessor :verify_depth

    # Sets the flags for server the certification verification at beginning of
    # SSL/TLS session.
    #
    # OpenSSL::SSL::VERIFY_NONE or OpenSSL::SSL::VERIFY_PEER are acceptable.
    attr_accessor :verify_mode


    def connect
      if proxy? then
        conn_address = proxy_address
        conn_port    = proxy_port
      else
        conn_address = address
        conn_port    = port
      end

      D "opening connection to #{conn_address}:#{conn_port}..."
      s = Timeout.timeout(@open_timeout, Net::OpenTimeout) {
        TCPSocket.open(conn_address, conn_port, @local_host, @local_port)
      }
      s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      D "opened"
      if use_ssl?
        ssl_parameters = Hash.new
        iv_list = instance_variables
        SSL_IVNAMES.each_with_index do |ivname, i|
          if iv_list.include?(ivname) and
            value = instance_variable_get(ivname)
            ssl_parameters[SSL_ATTRIBUTES[i]] = value if value
          end
        end
        @ssl_context = OpenSSL::SSL::SSLContext.new
        @ssl_context.set_params(ssl_parameters)
        D "starting SSL for #{conn_address}:#{conn_port}..."
        s = OpenSSL::SSL::SSLSocket.new(s, @ssl_context)
        s.sync_close = true
        D "SSL established"
      end
      @socket = BufferedIO.new(s)
      @socket.read_timeout = @read_timeout
      @socket.continue_timeout = @continue_timeout
      @socket.debug_output = @debug_output
      if use_ssl?
        begin
          if proxy?
            buf = "CONNECT #{@address}:#{@port} HTTP/#{HTTPVersion}\r\n"
            buf << "Host: #{@address}:#{@port}\r\n"
            if proxy_user
              credential = ["#{proxy_user}:#{proxy_pass}"].pack('m')
              credential.delete!("\r\n")
              buf << "Proxy-Authorization: Basic #{credential}\r\n"
            end
            buf << "\r\n"
            @socket.write(buf)
            HTTPResponse.read_new(@socket).value
          end
          s.session = @ssl_session if @ssl_session
          # Server Name Indication (SNI) RFC 3546
          s.hostname = @address if s.respond_to? :hostname=
          # Timeout.timeout(@open_timeout, Net::OpenTimeout) { s.connect }
          s.connect
          if @ssl_context.verify_mode != OpenSSL::SSL::VERIFY_NONE
            s.post_connection_check(@address)
          end
          @ssl_session = s.session
        rescue => exception
          D "Conn close because of connect error #{exception}"
          @socket.close if @socket and not @socket.closed?
          raise exception
        end
      end
      on_connect
    end
    private :connect

    def on_connect
    end
    private :on_connect

  end

end

# require 'net/http/exceptions'

# require 'net/http/header'

# require 'net/http/generic_request'
# require 'net/http/request'
# require 'net/http/requests'

# require 'net/http/response'
# require 'net/http/responses'

# require 'net/http/proxy_delta'

# require 'net/http/backward'

