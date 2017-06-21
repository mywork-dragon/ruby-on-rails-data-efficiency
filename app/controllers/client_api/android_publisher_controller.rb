class ClientApi::AndroidPublisherController < ApplicationController

  before_action :authenticate_client_api_request, only: [:show, :filter]

  def show
    id = params.fetch(:id)
    render json: AndroidDeveloper.find(id)
  end

  def filter
    domain = params.fetch(:domain)
    render json: AndroidDeveloper.find_by_domain(domain).map { |d| d.api_json }
  end
end
