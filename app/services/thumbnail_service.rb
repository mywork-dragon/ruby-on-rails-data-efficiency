class ThumbnailService
  class CredentialsMissing < RuntimeError; end
  def screenshot_url(url, options={})
      
    # set access key
    access_key = ENV['SCREENSHOTLAYER_ACCESS_KEY'] 
    
    # set secret keyword (defined in account dashboard)
    secret_keyword = ENV['SCREENSHOTLAYER_SECRET_KEYWORD']

    if access_key.nil?
      raise CredentialsMissing.new "SCREENSHOTLAYER_ACCESS_KEY"
    end

    if secret_keyword.nil?
      raise CredentialsMissing.new "SCREENSHOTLAYER_SECRET_KEYWORD"
    end
   
    # define parameters
    parameters = {
      :url       => url,
      :fullpage  => options[:fullpage],
      :width  => options[:width],
      :viewport  => options[:viewport],
      :format  => options[:format],
      :css_url  => options[:css_url],
      :delay  => options[:delay],
      :ttl  => options[:ttl],
      :force  => options[:force],
      :placeholder  => options[:placeholder],
      :user_agent  => options[:user_agent],
      :accept_lang  => options[:accept_lang],
      :export  => options[:export],
    }
     
    query = parameters.
      sort_by {|s| s[0].to_s }. 
      select {|s| s[1] }.       
      map {|s| s.map {|v| CGI::escape(v.to_s) }.join('=') }.
      join('&')
    
    # generate md5 secret key
    secret_key = Digest::MD5.hexdigest(url + secret_keyword)
   
    "https://api.screenshotlayer.com/api/capture?access_key=#{access_key}&secret_key=#{secret_key}&#{query}"
  end
end
