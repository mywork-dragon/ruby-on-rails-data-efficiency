# The controller for the API that we give to our customers
# Not to be confused with ApiController, which is our internal API to communicated with the frontend
# @author Jason Lew
class CustomerApiController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  # before_action :authenticate_request
  #
  # def authenticate_request
  #   render nothing: true, status: 401 if !ApiKey.find_by_key(key)
  # end

  def ios_apps
    render json: {'dummy' => 'show'}
  end
  
  def android_apps
    render json: {'dummy' => 'show'}
  end
  
  def companies
    render json: {'dummy' => 'show'}
  end

end
