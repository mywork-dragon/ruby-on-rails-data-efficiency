module BingSearcher

  include SearcherCommon

  class Searcher

    class << self

      def search(query)
        self.new.search(query)
      end

    end

    def initialize(jid: nil)
      @jid = jid
    end

    def search(query, proxy: nil, proxy_type: nil)
      @query = query
      query_url_safe = CGI::escape(query)
      p = Proxy.new(jid: @jid)
      @search_url = "http://www.bing.com/search?q=#{query_url_safe}"
      html_s = Tor.get(@search_url)
      Parser.parse(html_s, query: @query, search_url: @search_url)
    end

  end

  class Parser

    class << self

      def results(file)
        self.new.results(file)
      end

      def parse(html_s, query: nil, search_url: nil)
        self.new.parse(html_s, query: query)
      end

      def parse_file(file)
        raise "Haven't verified this works"
        self.new.parse_file(file)
      end
      
    end

    # Call this on a String of HTML
    # @author Jason Lew
    def parse(html_s, query: nil, search_url: nil)
      @query = query
      @search_url = search_url

      begin 
        @html = Nokogiri::HTML(html_s)
      rescue => e
        raise e, "Nokogiri could not parse HTML (Query: #{@query})"
      end

      # return @html #temp
    
      return count = parse_count
      results = (count == 0 ? [] : parse_results)

      SearcherCommon::Search.new(count: count, results: results, query: @query, search_url: @search_url)
    end

    def parse_file(file)
      parse File.open(file).read
    end

    private

    def parse_count
      results = @html.at_css('.sb_count')

      if results.nil? || (results_text = results.text).blank?

        detect_unusual_traffic_message

        if @html.at_css('.b_no').nil?
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
        begin
          h3_r_node = g.at_css('h3.r')
          url_node = h3_r_node.children.find{ |x| x.name = 'a' }

          url = url_node['href']
          url = clean_url(url)

          title = url_node.children.text

          summary = g.at_css('.st').text
          summary = nil if summary.blank?

          {title: title.chomp, url: url.chomp, summary: summary.chomp}
        rescue => e
          nil
        end
      end

      results_hash_a_compact = results_hash_a.compact

      results_hash_a_compact.each_with_index.map{ |results_hash, index| SearcherCommon::Result.new(title: results_hash[:title], url: results_hash[:url], summary: results_hash[:summary], result_num: index)}
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
      return
      # raise UnusualTrafficDetected, "(Query: #{@query})" if @html.text.include?('Our systems have detected unusual traffic')
    end

  end


end
