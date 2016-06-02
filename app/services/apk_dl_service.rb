require 'open-uri'

class ApkDlService

  def initialize(app_identifier=nil)
    @app_identifier = app_identifier
  end

  def attributes
    get_app_html
    
    methods = %w(
      download_page_link
      version  
    )

    @attributes = {}

    methods.each do |method|
      key = method.to_sym
      
      begin
        attribute = send(method.to_sym)
        @attributes[key] = attribute
      rescue
        @attributes[key] = nil
      end
    end

    @attributes
  end

  def get_app_html
    url = "http://apk-dl.com/#{@app_identifier}"
    page = Proxy.get_body_from_url(url)
    @app_html = Nokogiri::HTML(page)
  end

  def download_page_link
    @app_html.at_css('.download.btn.btn-success.btn-md')['href'].strip.gsub('//apk-dl.com', 'http://apk-dl.com')
  end

  def version
    @app_html.css('span').find{ |x| x.text.include?('Version: ') }.parent.children[1].text.strip
  end

  def dl_link
    page = Proxy.get_body_from_url(download_page_link)
    dl_html = Nokogiri::HTML(page)

    begin
      url = dl_html.css('p').find{ |x| x.text.include?("If the download doesn't start automatically in a few seconds, please") }.children.find{ |x| x.name == 'a' }['href'].strip
      ret = clean_url(url)
      puts "dl_link: #{ret}"
      ret
    # rescue
    #   nil
    end
  end

  def clean_url(url)
    f_regex = /\?(\w+)=(.*)\z/
    match = url.match(f_regex)
    fail "Could not find 2 capture groups" if match.size != 3
    key = match[1]
    value = match[2]
    value_escaped = CGI::escape(value)
    url.gsub(f_regex, "?#{key}=#{value_escaped}").gsub(/\A\/\//, 'http://')
  end

  def download(output_file)
    url = dl_link
    puts "Downloading file to #{output_file}"
    # download = open(url)
    # IO.copy_stream(download, output_file)
    curl_to_file(url: url, output_file: output_file)
    puts "Done downloading file to #{output_file}"
    true
  end

  def curl_to_file(url:, output_file:)
    `curl -o #{output_file} -vL #{url}`
    true
  end

  class << self

    def attributes(app_identifier)
      self.new(app_identifier)
    end


  end

end