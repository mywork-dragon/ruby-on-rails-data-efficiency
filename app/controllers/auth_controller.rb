class AuthController < ApplicationController

  skip_before_filter :verify_authenticity_token

  before_action :set_current_user, except: [:authenticate, :authenticate_provider]
  before_action :authenticate_request, except: [:authenticate, :authenticate_provider]

  def authenticate
    li 'AuthController.authenticate'

    user = User.find_by_credentials(params[:email], params[:password]) # you'll need to implement this

    if user && user.linkedin_uid.blank? && user.google_uid.blank?
      li "authenticated"
      render json: { auth_token: user.generate_auth_token, email: user.email}
    else
      li "authentication error"
      puts user
      message = if user.try(:linkedin_uid).present?
        "This account is connected to a LinkedIn account. Please use that to log in"
      elsif user.try(:google_uid).present?
        "This account is connected to a Google account. Please use that to log in"
      else
        'Invalid username or password'
      end
      render json: { error: message }, status: :unauthorized
    end
  end

  def authenticate_provider
    @oauth = "Oauth::#{params['provider'].classify}".constantize.new(params)

    if @oauth.authorized?
      email = @oauth.formatted_user_data.try(:[], :email)
      @user = User.from_auth(@oauth.formatted_user_data, params[:token])
      if @user
        regenerate = !params[:provider].include?('salesforce')
        render_success(auth_token: @user.generate_auth_token(regenerate), email: @user.email)
      else
        message = if params[:token]
          "This MightySignal invite has been claimed already or this #{params[:provider].titleize} login is linked to another MightySignal account"
        else
          opposite = params[:provider] == 'linkedin' ? 'Google' : 'LinkedIn'
          "We could not find a MightySignal account associated with this #{params['provider'].titleize} login. Try using #{opposite} login or email & password if you have not logged in using LinkedIn or Google previously."
        end
        render_error(message: message, email: email)
      end
    else
      render_error(message: "There was an error with #{params['provider'].titleize}. Please try again.")
    end
  end

  def render_data(data, status)
    render json: data, status: status, callback: params[:callback]
  end

  def render_error(message: nil, email: nil, status: :unprocessable_entity)
    render_data({ error: message, email: email }, status)
  end

  def render_success(data, status = :ok)
    if data.is_a? String
      render_data({ message: data }, status)
    else
      render_data(data, status)
    end
  end

  def permissions
    user = User.find(decoded_auth_token[:user_id])

    account = Account.find(user.account_id)

    render json: {
               can_view_support_desk: account.can_view_support_desk,
               can_view_ad_spend: account.can_view_ad_spend,
               can_view_ad_attribution: account.can_view_ad_attribution,
               can_view_sdks: account.can_view_sdks,
               can_view_storewide_sdks: account.can_view_storewide_sdks,
               can_view_exports: account.can_view_exports,
               is_admin: account.is_admin_account? || user.is_admin?,
               is_admin_account: account.is_admin_account?,
               can_view_ios_live_scan: account.can_view_ios_live_scan,
               connected_oauth: user.connected_oauth?,
               can_use_salesforce: user.account.can_use_salesforce?,
               sf_admin_connected: user.account.salesforce_uid.present?,
               sf_user_connected: user.salesforce_uid.present?,
               sf_installed: user.account.ready?,
               territories: user.territories,
               features: account.feature_flag_map
           }
  end

  def user_info
    user = User.find(decoded_auth_token[:user_id])
    render json: {
      email: user.email,
      account_id: user.account.id,
      account_name: user.account.name,
      salesforce_name: user.salesforce_name,
      salesforce_image_url: user.salesforce_image_url
    }
  end

  def account_info
    account = @current_user.account
    render json: {
      salesforce_settings: account.salesforce_settings,
      instance_url: account.salesforce_instance_url
    }
  end

end
