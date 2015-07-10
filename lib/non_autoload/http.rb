require 'net/protocol'
require 'uri'

module Net

  class HTTP < Protocol

    def initialize(address, port = nil)
      @address = address
      @port    = (port || HTTP.default_port)
      @local_host = nil
      @local_port = nil
      @curr_http_version = HTTPVersion
      @keep_alive_timeout = 2
      # I changed last_communicated from `nil` to `false`
      @last_communicated = false
      @close_on_empty_response = false
      @socket  = nil
      @started = false
      @open_timeout = nil
      @read_timeout = 60
      @continue_timeout = nil
      @debug_output = nil

      @proxy_from_env = false
      @proxy_uri      = nil
      @proxy_address  = nil
      @proxy_port     = nil
      @proxy_user     = nil
      @proxy_pass     = nil

      @use_ssl = false
      @ssl_context = nil
      @ssl_session = nil
      @enable_post_connection_check = true
      @sspi_enabled = false
      SSL_IVNAMES.each do |ivname|
        instance_variable_set ivname, nil
      end
    end

    def end_transport(req, res)
      @curr_http_version = res.http_version
      # I changed last_communicated from `nil` to `false`
      @last_communicated = false
      if @socket.closed?
        D 'Conn socket closed'
      elsif not res.body and @close_on_empty_response
        D 'Conn close'
        @socket.close
      elsif keep_alive?(req, res)
        D 'Conn keep-alive'
        @last_communicated = Time.now
      else
        D 'Conn close'
        @socket.close
      end
    end

  end

end