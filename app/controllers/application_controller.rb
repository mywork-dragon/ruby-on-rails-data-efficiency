class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  # force_ssl

  def ping
    render :json => {success: true}
  end
  
  private
    def current_salesforce_user
      @current_salesforce_user ||= SalesforceUser.find(session[:user_id]) if session[:user_id]
    end
    helper_method :current_salesforce_user
      
end
