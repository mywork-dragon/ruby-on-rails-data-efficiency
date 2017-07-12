class IosDeviceController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :authenticate_admin_account

  def filter
    query = IosDevice
    query = query.where(purpose: params.fetch(:purpose)) if params.has_key?(:purpose)
    query = query.where(id: params.fetch(:id)) if params.has_key?(:id)
    render json: query.all
  end

end
