class ErrorController < ApplicationController
  def not_found
    respond_to do |format|
      format.any(:json, :all) { render json: { error: 'Not Found' }, status: 404 }
      format.html { render file: 'public/404.html', status: 404, layout: false }
    end
  end

  def internal_error
    respond_to do |format|
      format.any(:json, :all) { render json: { error: 'Internal Server Error' }, status: 500 }
      format.html { render file: 'public/500.html', status: 500, layout: false }
    end
  end
end
