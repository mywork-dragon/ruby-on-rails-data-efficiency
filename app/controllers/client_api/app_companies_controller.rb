class ClientApi::AppCompaniesController < ApplicationController

  before_action :authenticate_client_api_request, only: [:show]

  def show
    developer_type = nil
    if developer_id = params[:ios_publisher_id]
      developer_type = 'IosDeveloper'
    elsif developer_id = params[:android_publisher_id]
      developer_type = 'AndroidDeveloper'
    end

    return render(json: { error: 'Unspecified publisher id' }, status: 400) if developer_type.nil?

    developer = AppDevelopersDeveloper.find_by!(developer_id: developer_id, developer_type: developer_type).app_developer
    render json: developer
  end
end
