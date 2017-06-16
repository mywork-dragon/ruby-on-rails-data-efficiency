class ClientApi::AndroidSdkController < ApplicationController

  before_action :authenticate_client_api_request, only: :show

  def show
    id = params.fetch(:id)
    render json: AndroidSdk.display_sdks.find(id).api_json
  end
end
