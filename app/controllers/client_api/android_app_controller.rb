class ClientApi::AndroidAppController < ApplicationController

  before_action :limit_client_api_call, only: [:show, :filter, :show_classes]
  after_action :bill_api_request

  def show_classes
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('android_app_show_classes')
    snap = AndroidApp.find(params.fetch(:id)).newest_apk_snapshot
    if !snap.nil? and ! snap.apk_file.nil?
      return render json: snap.apk_file.classes
    end
    render :json => {"message" => "Classes not available"},  :status => 404
  end

  def show
    app_identifier = params.fetch(:app_identifier)
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('android_app_show')
    render json: AndroidApp.find_by!(app_identifier: app_identifier).api_json
  end

  def filter
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('android_app_filter')
    filter = AppFilter.new(
      app_model: AndroidApp,
      es_client: AppsIndex::AndroidApp,
      query_params: params,
      platform: :android
    )
    filter.search!
    render json: filter.result
  end
end
