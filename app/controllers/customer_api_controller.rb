# The controller for the API that we give to our customers
# Not to be confused with ApiController, which is our internal API to communicated with the frontend
# @author Jason Lew
class CustomerApiController < ApplicationController
  
  skip_before_filter :verify_authenticity_token

  def ios_apps
  end
  
  def android_apps
  end
  
  def companies
    
    render json: {'dummy' => 'show'}
    
  end

end
