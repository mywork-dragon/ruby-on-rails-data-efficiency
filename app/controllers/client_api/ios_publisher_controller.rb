class ClientApi::IosPublisherController < ApplicationController

  before_action :authenticate_client_api_request, only: [:show, :filter]

  def show
    id = params.fetch(:id)
    render json: IosDeveloper.find(id).api_json
  end

  def filter
    domain = params.fetch(:domain)
    render json: IosDeveloper.find_by_domain(domain).map { |d| d.api_json }
  end
end
