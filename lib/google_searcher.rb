module GoogleSearcher

  class Searcher

    class << self

      def search(query, proxy: nil, proxy_type: nil)
        self.new.search(query, proxy: proxy, proxy_type: proxy_type)
      end

    end

    def search(query, proxy: nil, proxy_type: nil)
      html_s = Proxy.get_body(req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => query}, proxy: proxy, proxy_type: proxy_type)
      Parser.parse(html_s)
    end

  end

  class Parser

    class << self

      def results(file)
        self.new.results(file)
      end

      def parse(html_s)
        self.new.parse(html_s)
      end

      def parse_file(file)
        self.new.parse_file(file)
      end
      
    end

    # Call this on a String of HTML
    # @author Jason Lew
    def parse(html_s)
      begin 
        @html = Nokogiri::HTML(html_s)
      rescue => e
        raise e, "Nokogiri could not parse HTML"
      end
    
      count = parse_count
      results = (count == 0 ? [] : parse_results)

      Search.new(count: count, results: results)
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
          raise HtmlInvalid, "Couldn't match regex /Your search - .* - did not match any documents./ on page"
        end
        
      end

      return 0 if results.nil?

      results_text = results.text
      return 0 if results_text.blank?

      /(?<results_count>\S+) results/ =~ results_text
      results_count.gsub(',', '').to_i
    end

    def parse_results
      begin
        gs = @html.css('.g')
      rescue => e
        detect_unusual_traffic_message
        raise HtmlInvalid, "Couldn't find '.g' selector"
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

      results_hash_a_compact.each_with_index.map{ |results_hash, index| Result.new(title: results_hash[:title], url: results_hash[:url], summary: results_hash[:summary], result_num: index)}
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
      raise UnusualTrafficDetected if @html.text.include?('Our systems have detected unusual traffic')
    end

  end

  class Search
    attr_reader :count
    attr_reader :results

    def initialize(count:, results:)
      @count = count
      @results = results
    end
  end

  class Result
    attr_reader :title
    attr_reader :url
    attr_reader :summary
    attr_reader :result_num

    def initialize(title:, url:, summary:, result_num:)
      @title = title
      @url = url
      @summary = summary
      @result_num = result_num
    end

  end

  class HtmlInvalid < StandardError

    def initialize(message = "Cannot find critical selector in HTML. Check your HTML to make sure it's valid.")
      super
    end

  end

  class UnusualTrafficDetected < StandardError

    def initialize(message = "Unusual traffic detected")
      super
    end

  end


end
