class IosDeviceController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :authenticate_admin_account

  def filter
    query = IosDevice
    query = query.where(purpose: params.fetch(:purpose)) if params.has_key?(:purpose)
    query = query.where(id: params.fetch(:id)) if params.has_key?(:id)
    render json: query.all
  end

  def enable_device
    device = IosDevice.where(:id => params[:id])
    if device.empty?
      render json: { success: false }, status: 404 
    else
      device.update_all(:disabled => false)
      render json: { success: true }, status: 200
    end
  end

  def disable_device
    device = IosDevice.where(:id => params[:id])
    if device.empty?
      render json: { success: false }, status: 404 
    else
      device.update_all(:disabled => true)
      render json: { success: true }, status: 200
    end
  end

end
