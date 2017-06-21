class ClientApi::AndroidAppController < ApplicationController

  before_action :authenticate_client_api_request, only: [:show]

  def show
    app_identifier = params.fetch(:app_identifier)
    render json: AndroidApp.find_by!(app_identifier: app_identifier).api_json
  end
end
