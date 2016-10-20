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

    # Run a search
    def search(query, proxy_type: :android_classification)
      @query = query
      query_url_safe = CGI::escape(query)
      html_s = BingSearch.query(query_url_safe, proxy_type: proxy_type)
      
      Parser.parse(html_s, query: @query, search_url: @search_url)
    end

  end

  class Parser

    class << self

      def results(file)
        self.new.results(file)
      end

      def parse(html_s, query: nil, search_url: nil)
        self.new.parse(html_s, query: query, search_url: search_url)
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
    
      count = parse_count
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

        if !@html.text.match(/No results found for/)
          raise SearcherCommon::HtmlInvalid, "Couldn't match regex /No results found for/ on page (Query: #{@query})"
        end
        
      end

      return 0 if results.nil?

      results_text = results.text
      return 0 if results_text.blank?

      /(?<results_count>\S+) results?/ =~ results_text

      if defined?(results_count) && results_count
        return results_count.gsub(',', '').to_i
      else
        raise SearcherCommon::HtmlInvalid, "Couldn't find number of results text in HTML (Query: #{@query})"
      end
      
    end

    def parse_results
      begin
        b_algos = @html.css('.b_algo')
      rescue => e
        detect_unusual_traffic_message
        raise SearcherCommon::HtmlInvalid, "Couldn't find '.b_algo' selector (Query: #{@query})"
      end

      results_hash_a = b_algos.map do |b_algo|
        begin
          h2_node = b_algo.at_css('h2')
          url_node = h2_node.children.find{ |x| x.name = 'a' }

          url = url_node['href']

          title = url_node.text

          b_factrownosep = b_algo.at_css('.b_factrownosep')
          subtitle = b_factrownosep ? b_factrownosep.text : nil

          summary = b_algo.at_css('.b_caption').at_css('p').text
          summary = nil if summary.blank?

          {title: title.strip, subtitle: subtitle, url: url.strip, summary: summary.strip}
        rescue => e
          nil
        end
      end

      results_hash_a_compact = results_hash_a.compact

      results_hash_a_compact.each_with_index.map{ |results_hash, index| SearcherCommon::Result.new(title: results_hash[:title], subtitle: results_hash[:subtitle], url: results_hash[:url], summary: results_hash[:summary], result_num: index)}
    end

    def detect_unusual_traffic_message
      return
      # raise SearcherCommon::UnusualTrafficDetected, "(Query: #{@query})" if @html.text.include?('Our systems have detected unusual traffic')
    end

  end


end
