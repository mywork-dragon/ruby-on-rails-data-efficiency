class AuthController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  def authenticate
    li 'AuthController.authenticate'
    
    user = User.find_by_credentials(params[:email], params[:password]) # you'll need to implement this
    
    if user
      li "authenticated"
      render json: { auth_token: user.generate_auth_token, email: user.email}
    else
      li "authentication error"
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

  def permissions
    user = User.find(decoded_auth_token[:user_id])

    account = Account.find(user.account_id)

    render json: { :can_view_support_desk => account.can_view_support_desk, :can_view_ad_spend => account.can_view_ad_spend }
  end
  
end