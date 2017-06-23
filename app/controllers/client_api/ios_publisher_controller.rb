class ClientApi::IosPublisherController < ApplicationController

  before_action :limit_client_api_call, only: [:show, :filter]
  after_action :bill_api_request

  def show
    id = params.fetch(:id)
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('ios_publisher_show')
    render json: IosDeveloper.find(id).api_json
  end

  def filter
    domain = params.fetch(:domain)
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('ios_publisher_filter')
    render json: IosDeveloper.find_by_domain(domain).map { |d| d.api_json }
  end
end
