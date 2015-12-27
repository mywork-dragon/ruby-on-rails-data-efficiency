class GoogleParser

  class << self
    def results(file)
      self.new.results(file)
    end
  end

  # TODO: UTF-8
  # TODO: replace google params
  def results(file)
    html_text = File.open(file).read

    begin 
      html = Nokogiri::HTML(html_text)
    rescue => e
      raise "Nokogiri could not parse HTML"
    end

    begin
      gs = html.css('.g')
    rescue => e
      raise_could_not_find_any_results_exception
    end

    results_hash = gs.map do |g|
      begin
        h3_r_node = g.at_css('h3.r')
        url_node = h3_r_node.children.find{ |x| x.name = 'a' }

        url = url_node['href']
        url = clean_url(url)

        title = url_node.children.text

        summary = g.at_css('.st').text

        {title: title, url: url, summary: summary}
      rescue => e
        nil
      end
    end

    results_hash_compact = results_hash.compact

    raise_could_not_find_any_results_exception if results_hash_compact.empty?

    results_hash_compact
  end

  def raise_could_not_find_any_results_exception
    raise "Could not find any results" 
  end

  # url can look like, so probably need to clean it
    # /url?q=https://parse.com/docs/ios/guide&sa=U&ved=0ahUKEwi8k7uju_zJAhVDwGMKHahiC7YQFggUMAA&usg=AFQjCNHYJPQQ7P9b6EhPqFJZSXxk_4_RCw
  def clean_url(url)
    if url.starts_with?('/url?q=')
        url.sub!('/url?q=', '')
        # TODO: replace 'sa' and 'sg' params on URL
      end
      url
  end


end