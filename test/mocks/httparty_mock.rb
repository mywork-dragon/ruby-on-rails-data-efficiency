class HttpartyMock

  class Unregistered < RuntimeError; end

  def initialize
    @responses = {}
  end

  # request must contain url and any option keys 
  # response much contain body, code
  def register(request, response)
    key = {
      url: request.fetch(:url),
      options: request[:options] || {}
    }
    value = Response.new(
      response.fetch(:body),
      response.fetch(:code),
      headers: response[:headers] || {})
    @responses[key] = value
  end

  def get(url, options={})
    key = {
      url: url,
      options: options
    }
    res = @responses[key]
    raise Unregistered, key unless res
    res
  end

  class Response
    attr_accessor :body, :code, :headers

    def initialize(body, code, headers: {})
      @body = body
      @code = code
      @headers = headers
    end
  end
end
