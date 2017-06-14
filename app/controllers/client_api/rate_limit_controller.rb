class ClientApi::RateLimitController < ApplicationController

  before_action :authenticate_client_api_request, only: :show

  def show
    token = @http_client_api_auth_token
    render json: Throttler.new(token.token, token.rate_limit, token.period).status
  end
end
