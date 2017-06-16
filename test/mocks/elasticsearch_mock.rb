class ElasticsearchMock
  class UnregisteredQuery < RuntimeError; end

  attr_accessor :responses

  def initialize
    @responses = {}
  end

  # k - input hash of params
  # v - array of expected app hashes from ES
  def add_response(k, v)
    @responses[k] = AppResponse.new(v)
  end

  def query(terms)
    if @responses[terms]
      @responses[terms]
    else
      raise UnregisteredQuery
    end
  end

  class AppResponse

    def initialize(documents)
      @response = documents.map { |d| AppMock.new(d) }
    end

    def to_a
      @response
    end

    def total_count
      @response.count
    end

  end

  class AppMock

    attr_accessor :app_doc

    ATTRIBUTES = [:id, :name]

    ATTRIBUTES.each do |name|
      define_method(name.to_sym) { @app_doc[name.to_sym] || @app_doc[name.to_s] || nil }
    end

    def initialize(app_doc = {})
      @app_doc = app_doc
    end
  end
end
