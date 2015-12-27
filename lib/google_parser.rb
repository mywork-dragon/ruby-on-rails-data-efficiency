module GoogleParser

  class Parser

    class << self
      def results(file)
        self.new.results(file)
      end

      # def parse(html_s)
      #   self.new.parse(html_s)
      # end

      def parse(file)
        self.new.parse(file)
      end
    end

    # TODO: UTF-8
    # TODO: replace google params
    def parse(file)
      html_text = File.open(file).read

      begin 
        @html = Nokogiri::HTML(html_text)
      rescue => e
        raise "Nokogiri could not parse HTML"
      end
    
      AllResults.new(results: parse_results, count: 70)
    end

    private

    def parse_results
      begin
        gs = @html.css('.g')
      rescue => e
        raise_could_not_find_any_results_exception
      end

      results_hash_a = gs.map do |g|
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

      results_hash_a_compact = results_hash_a.compact

      raise_could_not_find_any_results_exception if results_hash_a_compact.empty?

      results_hash_a_compact.map{ |results_hash| Result.new(title: results_hash[:title], url: results_hash[:url], summary: results_hash[:summary]) }
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

  class AllResults
    attr_reader :count
    attr_reader :results

    def initialize(count:, results:)
      @count = count
      @results = results
    end
  end

  class Result
    attr_reader :titles
    attr_reader :url
    attr_reader :summary

    def initialize(title:, url:, summary:)
      @title = title
      @url = url
      @summary = summary
    end

  end

end
