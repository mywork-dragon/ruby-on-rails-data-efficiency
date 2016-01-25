module SearcherCommon

  class Search
    attr_reader :count
    attr_reader :results
    attr_reader :query
    attr_reader :search_url

    def initialize(count:, results:, query: nil, search_url: nil)
      @count = count
      @results = results
      @query = query
      @search_url = search_url
    end
  end

  class Result
    attr_reader :title
    attr_reader :subtitle
    attr_reader :url
    attr_reader :summary
    attr_reader :result_num

    def initialize(title:, subtitle: , url:, summary:, result_num:)
      @title = title
      @subtitle = subtitle
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