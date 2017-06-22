class ElasticsearchMock
  class UnregisteredQuery < RuntimeError; end

  attr_accessor :responses

  def initialize
    @responses = {}
  end

  # k - input hash of params
  # v - array of expected app hashes from ES
  def add_response(k, v)
    @responses[k] = Query.new(k,v)
  end

  def query(terms)
    if @responses[terms]
      @responses[terms]
    else
      raise UnregisteredQuery, terms
    end
  end

  class Query

    attr_accessor :_query, :_order, :_limit, :_offset

    def initialize(query,value)
      @_query = query
      @value = AppResponse.new(value)
    end

    def order(order)
      @_order = order
      self
    end

    def limit(limit)
      @_limit = limit
      self
    end

    def offset(offset)
      @_offset = offset
      self
    end

    [:first, :to_a, :total_count].each do |sym|
      define_method(sym.to_sym) { @value.send(sym) }
    end

  end

  class AppResponse

    def initialize(documents)
      @response = documents.map { |d| AppMock.new(d) }
    end

    def first
      @response.first
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

    def attributes
      @app_doc
    end
  end
end
