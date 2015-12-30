module SearcherCommon

  puts "module CommonSearcher"

  class Search
    attr_reader :count
    attr_reader :results
    attr_reader :query

    def initialize(count:, results:, query: nil)
      @count = count
      @results = results
      @query = query
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