module GoogleSearcher

  include SearcherCommon

  class Searcher

    class << self

      def search(query, proxy: nil, proxy_type: nil)
        self.new.search(query, proxy: proxy, proxy_type: proxy_type)
      end

    end

    def initialize(jid: nil)
      @jid = jid
    end

    def search(query, proxy: nil, proxy_type: nil)
      @query = query
      p = Proxy.new(jid: @jid)

      # http://stackoverflow.com/questions/23995700/what-is-the-porpose-of-the-google-search-parameter-gbv
      html_s = p.get_body(req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => query, 'gbv' => '1'}, proxy: proxy, proxy_type: proxy_type)
      
      Parser.parse(html_s, query: query)
    end

  end

  class Parser

    class << self

      def results(file)
        self.new.results(file)
      end

      def parse(html_s, query: nil)
        self.new.parse(html_s, query: query)
      end

      def parse_file(file)
        self.new.parse_file(file)
      end
      
    end

    # Call this on a String of HTML
    # @author Jason Lew
    def parse(html_s, query: nil)
      @query = query

      begin 
        @html = Nokogiri::HTML(html_s)
      rescue => e
        raise e, "Nokogiri could not parse HTML (Query: #{@query})"
      end
    
      count = parse_count
      results = (count == 0 ? [] : parse_results)

      SearcherCommon::Search.new(count: count, results: results, query: query)
    end

    def parse_file(file)
      parse File.open(file).read
    end

    private

    def parse_count
      results = @html.at_css('#resultStats')

      if results.nil? || (results_text = results.text).blank?

        detect_unusual_traffic_message

        if !@html.text.match(/Your search - .* - did not match any documents./)
          raise HtmlInvalid, "Couldn't match regex /Your search - .* - did not match any documents./ on page (Query: #{@query})"
        end
        
      end

      return 0 if results.nil?

      results_text = results.text
      return 0 if results_text.blank?

      /(?<results_count>\S+) results?/ =~ results_text

      if defined?(results_count)
        return results_count.gsub(',', '').to_i
      else
        raise HtmlInvalid, "Couldn't find number of results text in HTML (Query: #{@query})"
      end
      
    end

    def parse_results
      begin
        gs = @html.css('.g')
      rescue => e
        detect_unusual_traffic_message
        raise HtmlInvalid, "Couldn't find '.g' selector (Query: #{@query})"
      end

      results_hash_a = gs.map do |g|
        h3_r_node = g.at_css('h3.r')
        
        next nil if h3_r_node.nil?
        
        url_node = h3_r_node.children.find{ |x| x.name = 'a' }

        url = url_node['href']
        url = clean_url(url)
        url.strip!

        title = url_node.children.text.strip

        subtitle_node = g.at_css('.f.slp')
        subtitle = subtitle_node.nil? ? nil : subtitle_node.text.strip

        summary_node = g.at_css('.st')
        summary = summary_node.nil? ? nil : summary_node.text.strip

        {title: title, subtitle: subtitle, url: url, summary: summary}
      end.compact

      raise HtmlInvalid, "Couldn't find h3.r selector for anything on page" if results_hash_a.empty?

      results_hash_a_compact = results_hash_a.compact

      results_hash_a_compact.each_with_index.map{ |results_hash, index| SearcherCommon::Result.new(title: results_hash[:title], subtitle: results_hash[:subtitle], url: results_hash[:url], summary: results_hash[:summary], result_num: index)}
    end

    # url can look like, so probably need to clean it
    # /url?q=https://parse.com/docs/ios/guide&sa=U&ved=0ahUKEwi8k7uju_zJAhVDwGMKHahiC7YQFggUMAA&usg=AFQjCNHYJPQQ7P9b6EhPqFJZSXxk_4_RCw
    def clean_url(url)
      if url.starts_with?('/url?q=')
          url.sub!('/url?q=', '')
          url.gsub!(/(&*)sa=(.*)&ved=(.*)&usg=(.*)/, '')
        end
      url
    end

    def detect_unusual_traffic_message
      raise UnusualTrafficDetected, "(Query: #{@query})" if @html.text.include?('Our systems have detected unusual traffic')
    end

  end


end
