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
    
    begin
      response = SalesforceExportService.new(user: @current_user, 
                                model_name: params[:model])
                               .export(
                                app: app, 
                                mapping: params[:mapping], 
                                object_id: params[:objectId]) 
    rescue StandardError => e
      render json: {error_class: e.class.name, error_message: e.message}, status: 400
    else
      render json: {id: response}
    end
  end

end