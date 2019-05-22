# Couldn't find where this is used

# class ProxyTestService
#
#   class << self
#
#     def test(ip, port: 8888)
#       JSON.load(
#         open('https://wtfismyip.com/json',
#           allow_redirections: :all,
#           "User-Agent" => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36',
#           proxy: URI::parse("http://#{ip}:#{port}")
#           )
#         )
#     end
#   end
# end
