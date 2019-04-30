class ClientApi::AndroidPublisherController < ApplicationController

  before_action :limit_client_api_call, only: [:show, :filter]
  after_action :bill_api_request

  def show
    id = params.fetch(:id)
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('android_publisher_show')
    render json: AndroidDeveloper.find(id).api_json
  end

  def filter
    domain = params.fetch(:domain)
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('android_publisher_filter')
    render json: AndroidDeveloper.find_by_domain(domain).map { |d| d.api_json }
  end

  def contacts
    publisher_id = params.fetch(:publisher_id)
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('android_contacts')
    developer = AndroidDeveloper.find(publisher_id)
    render json: ClearbitContact.get_contacts_for_developer(developer, nil).as_json
  rescue ActiveRecord::RecordNotFound => e
    render json: {error: e.to_s}, status: :not_found
  end
end
