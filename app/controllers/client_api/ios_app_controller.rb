class ClientApi::IosAppController < ApplicationController

  before_action :limit_client_api_call, only: [:show, :filter, :show_classes]
  after_action :bill_api_request

  def show_classes
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('ios_app_show_classes')
    snap = IosApp.find(params.fetch(:id)).newest_ipa_snapshot
    if !snap.nil? and ! snap.class_dumps.last.nil?
      return render json: snap.class_dumps.last.all_classes
    end
    render :json => {"message" => "Classes not available"},  :status => 404
  end

  def show
    app_identifier = params[:app_identifier]
    id = params[:id]
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('ios_app_show')
    if app_identifier.present?
      return render json: IosApp.find_by!(app_identifier: app_identifier).api_json
    elsif id.present?
      return render json: IosApp.find(id).api_json
    else
      render :json => {"message" => "Neither app_identifier nor id was provided"},  :status => 400
    end
  end

  def filter
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('ios_app_filter')
    filter = AppFilter.new(
      app_model: IosApp,
      es_client: AppsIndex::IosApp,
      query_params: params,
      platform: :ios
    )
    filter.search!
    render json: filter.result
  end
end
