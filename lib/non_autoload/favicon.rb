# WWW::Favicon.module_eval do

#     def request(url, options = {})
#       method = options[:method] || :get
#       redirection_limit = options[:redirection_limit] || 10

#       mp = MicroProxy.transaction do

#         p = MicroProxy.lock.order(last_used: :asc).first
#         p.last_used = DateTime.now
#         p.save

#         p

#       end

#       uri = URI(url)
#       http = Net::HTTP.SOCKSProxy(mp.private_ip, '8888').new(uri.host, uri.port)

#       if uri.scheme == 'https'
#         http.use_ssl = true
#         http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#       end

#       response = http.start do |http|
#         path =
#           (uri.path.empty? ? '/' : uri.path) +
#           (uri.query       ? '?' + uri.query : '') +
#           (uri.fragment    ? '#' + uri.fragment : '')
#         http.send(method, path)
#       end

#       if response.kind_of?(Net::HTTPRedirection) && redirection_limit > 0
#         request(response['Location'], :redirection_limit => redirection_limit - 1)
#       else
#         response.instance_variable_set('@request_url', url)
#         def response.request_url; @request_url; end
#         response
#       end
#     end

# end