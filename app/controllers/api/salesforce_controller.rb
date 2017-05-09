class Api::SalesforceController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_action :set_current_user, :authenticate_request

  def search
    model = params[:model] 
    query = params[:query] 

    results = SalesforceExportService.new(user: @current_user, model_name: params[:model]).search(query)
    render json: {results: results}
  end

  def export
    app = if params[:ios_app_id]
      IosApp.find(params[:ios_app_id])
    elsif params[:android_app_id]
      AndroidApp.find(params[:android_app_id])
    end
    
    response = SalesforceExportService.new(user: @current_user, 
                                model_name: params[:model])
                               .export_app(
                                app: app, 
                                mapping: params[:mapping], 
                                object_id: params[:objectId]) 
    render json: {success: response}
  end

end