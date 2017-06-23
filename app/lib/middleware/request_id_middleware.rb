# Custom middleware to use ALB Request ID as Rails request id
# based on: https://github.com/rails/rails/blob/4-2-stable/actionpack/lib/action_dispatch/middleware/request_id.rb
class RequestIdMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    env['action_dispatch.request_id'] = external_request_id(env) || internal_request_id
    @app.call(env).tap { |_status, headers, _body| headers["X-Request-Id"] = env["action_dispatch.request_id"] }
  end

  private

  # look for ALB header first and allow for additional characters
  def external_request_id(env)
    if request_id = env['HTTP_X_AMZN_TRACE_ID'].presence || env["HTTP_X_REQUEST_ID"].presence
      request_id.gsub(/[^\w\-=;]/, "").first(255)
    end
  end

  def internal_request_id
    SecureRandom.uuid
  end
end
