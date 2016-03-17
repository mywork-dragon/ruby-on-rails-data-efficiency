class Proxy

  class << self

    def get(req:, params: {}, type: :get, proxy: nil, proxy_type: nil, randomize_user_agent: true) 
      self.new.get(req: req, params: params, type: type, proxy: proxy, proxy_type: proxy_type, randomize_user_agent: randomize_user_agent) 
    end

    def get_body(req:, params: {}, type: :get, proxy: nil, proxy_type: nil)
      self.new.get_body(req: req, params: params, type: type, proxy: proxy, proxy_type: proxy_type)
    end

    def get_nokogiri(req:, params: {}, type: :get, proxy_type: nil)
      self.new.get_nokogiri(req: req, params: params, type: type, proxy_type: proxy_type)
    end

    def get_nokogiri_with_wait(req:, params: {}, type: :get)
      self.new.get_nokogiri_with_wait(req: req, params: params, type: type)
    end

    def get_from_url(url, params: {}, headers: {}, proxy: nil, proxy_type: nil)
      self.new.get_from_url(url, params: params, headers: headers, proxy: proxy, proxy_type: proxy_type)
    end

    def params_from_query(query)
      self.new.params_from_query(query)
    end

    def get_body_from_url(url, params: {}, headers: {}, proxy: nil, proxy_type: nil)
      self.new.get_body_from_url(url, params: params, headers: headers, proxy: proxy, proxy_type: proxy_type)
    end

  end

  def initialize(jid: nil)
    @jid = jid
  end

  # Get the response from a get request
  # If get fails, will throw an error
  # @author Stephen Kennedy
  # @author Osman Khwaja
  # @author Jason Lew
  # @return The response (CurbFu::Response::Base)
  # @note Will run from local IP if not in production mode
  def get(req:, params: {}, type: :get, proxy: nil, proxy_type: nil, randomize_user_agent: true) 

    # randomize User-Agent
    if randomize_user_agent
      user_agent_header = {'User-Agent' => UserAgent.random_web}
      headers = req[:headers]
      req[:headers] = (headers.nil? ? user_agent_header : headers.merge(user_agent_header))

      # puts "Headers: ".yellow
      # ap req[:headers]
      # puts ''
    end

    if Rails.env.production?
      
      mp = proxy || get_proxy_by_type(type: proxy_type)
      
      proxy = "#{mp}:8888"

      return CurbFu.send(type, req, params) do |curb|

        # Defaults
        curb.proxy_url = proxy
        curb.ssl_verify_peer = false
        curb.max_redirects = 3
        curb.follow_location = true
        curb.timeout = 120

        curb.on_complete do |curl_response|
          configure_curb_encoding(curl_response)
        end

        yield(curb) if block_given? # Can override
      end

    else

      return CurbFu.send(type, req, params) do |curb|

        # Defaults
        curb.follow_location = true
        curb.ssl_verify_peer = false
        curb.max_redirects = 3
        curb.timeout = 120

        curb.on_complete do |curl_response|
          configure_curb_encoding(curl_response)
        end

        

        yield(curb) if block_given? # Can override
      end

    end

  end

  def get_proxy_by_type(type: nil)

    # ios and android share...for now

    proxies = if type == :ios_classification
      ios_proxies
    elsif type == :android_classification
      android_proxies
    else
      general_proxies
    end

    proxies.sample
  end

  # Get a proxy depending on the current thread
  def unique_proxy_per_thread(queue:)
    raise "#@jid is nil, but it can't be" if @jid.nil?

    workers = Sidekiq::Workers.new

    my_worker = nil

    workers_for_queue = workers.map do |process_id, thread_id, work|
      next if work['queue'] != queue

      my_worker = {process_id: process_id, thread_id: thread_id} if work['payload']['jid'] == @jid

      {process_id: process_id, thread_id: thread_id}
    end.compact

    workers_for_queue_sorted = workers_for_queue.sort_by{ |x| [x[:process_id], x[:thread_id]] }

    my_worker_thread_id = my_worker[:thread_id]
    proxy_index = workers_for_queue_sorted.index{ |x| x[:thread_id] == my_worker_thread_id}

    puts "proxy_index: #{proxy_index}"

    android_proxies[proxy_index]
  end

  # Gets the body only
  # @author Jason Lew
  # @return The body (String)
  def get_body(req:, params: {}, type: :get, proxy: nil, proxy_type: nil)
    get(req: req, params: params, type: type, proxy: proxy, proxy_type: proxy_type).body
  end

  # Get the body as Nokogiri
  # @author Jason Lew
  # @return A Nokogiri::HTML::Document of the page
  def get_nokogiri(req:, params: {}, type: :get, proxy_type: nil)
    proxy = proxy_type.nil? ? nil : get_proxy_by_type(type: proxy_type)
    Nokogiri::HTML(get_body(req: req, params: params, type: type, proxy: proxy, proxy_type: proxy_type))
  end

  def get_nokogiri_with_wait(req:, params: {}, type: :get)
    body = nil
    5.times do
      begin
        sleep(rand(0.0..1.0))
        body = Nokogiri::HTML(get_body(req: req, params: params, type: type))
      rescue
        nil
      else
        break
      end
    end
    body
  end

  # Convenience method to get the Response object from just a url
  # @author Osman Khwaja
  # @return The response (CurbFu::Response::Base)
  def get_from_url(url, params: {}, headers: {}, proxy: nil, proxy_type: nil,randomize_user_agent: true)
    uri = URI(url)
    get(req: {host: uri.host + uri.path, protocol: uri.scheme, headers: headers}, params: params_from_query(uri.query).merge(params), randomize_user_agent: randomize_user_agent, proxy: proxy, proxy_type: proxy_type)
  end

  # from a query string, build the params object
  # "id=368677368&uslimit=1" --> {"id"=>"368677368", "uslimit"=>"1"}
  def params_from_query(query)

    return {} if query.nil?

    query.split("&").reduce({}) do |memo, pair|
      parts = pair.split("=")
      if parts.length > 1
        memo[parts.first] = parts.second
        memo
      else
        memo
      end
    end
  end

  # Get the body, passing in only the URL
  # @author Jason Lew
  # @url The URL to get
  # @param The HTTP params
  # @return The body (String)
  def get_body_from_url(url, params: {}, headers: {}, proxy: nil, proxy_type: nil)
    uri = URI(url)
    get_body(req: {host: uri.host + uri.path, protocol: uri.scheme, headers: headers}, params: params_from_query(uri.query).merge(params), proxy: proxy, proxy_type: proxy_type)
  end

  def general_proxies
    MicroProxy.where(purpose: MicroProxy.purposes[:general], active:true).pluck(:private_ip)
  end

  def ios_proxies
    MicroProxy.where(purpose: MicroProxy.purposes[:ios], active:true).pluck(:private_ip)
  end

  def android_proxies
    ios_proxies
  end

  private 

  # Support UTF-8
  # https://github.com/vcr/vcr/issues/150#issuecomment-4648446
  # @author Jason Lew
  def configure_curb_encoding(curl_response)
    encoding = 'UTF-8'
    encoding = $1 if curl_response.header_str =~ /charset=([-a-z0-9]+)/i
    encoding = $1 if curl_response.body_str =~ %r{<meta[^>]+content=[^>]*charset=([-a-z0-9]+)[^>]*>}mi
    curl_response.body_str.force_encoding(encoding)
  end

end