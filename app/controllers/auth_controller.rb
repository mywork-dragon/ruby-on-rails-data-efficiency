class AuthController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  #skip_before_action :authenticate_request # this will be implemented later
  
  def authenticate
    li 'AuthController.authenticate'
    
    user = User.find_by_credentials(params[:email], params[:password]) # you'll need to implement this
    
    if user
      render json: { auth_token: user.generate_auth_token }
    else
      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end
  
  # don't use this yet
  def validate_token
    # token = params[:]
    # decoded_auth_token = AuthToken.decode(http_auth_header_content)
    #
    # render true if decoded_auth_token && User.find(decoded_auth_token[:user_id]) && !decoded_auth_token
    #
    # return false
  end
  
end