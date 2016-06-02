require 'open-uri'

class ApkDlService

  def initialize(app_identifier)
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
      f_regex = /\?(\w+)=(.*)\z/
      url = dl_html.css('p').find{ |x| x.text.include?("If the download doesn't start automatically in a few seconds, please") }.children.find{ |x| x.name == 'a' }['href'].strip.gsub(' ', '%20')
      match = url.match(f_regex)
      fail "Could not find 2 capture groups" if match.size != 3
      key = match[1]
      value = match[2]
      value_escaped = CGI::escape(value)
      url.gsub(f_regex, "?#{key}=#{value_escaped}")
    # rescue
    #   nil
    end
  end

  def download(output_file)
    url = dl_link
    puts "Downloading file to #{output_file}"
    download = open(url)
    IO.copy_stream(download, output_file)
    puts "Done downloading file to #{output_file}"
    true
  end

  class << self

    def attributes(app_identifier)
      self.new(app_identifier)
    end


  end

end