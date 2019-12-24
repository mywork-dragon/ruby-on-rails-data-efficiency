class ErrorController < ApplicationController
  def not_found
    respond_to do |format|
      format.any(:json, :all) { render json: { error: 'Not Found' }, status: 404 }
      format.html { render 'error/not_found', status: 404, layout: 'marketing' }
    end
  end

  def internal_error
    respond_to do |format|
      format.any(:json, :all) { render json: { error: 'Internal Server Error' }, status: 500 }
      format.html { render 'error/internal_error', status: 500, layout: 'marketing' }
    end
  end
end
