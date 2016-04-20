class Api::AdminController < ApplicationController

  skip_before_filter  :verify_authenticity_token
  before_action :set_current_user, :authenticate_request
  before_action :authenticate_admin

  def index
    accounts = if @current_user.account.is_admin_account?
      Account.all
    else
      [@current_user.account]
    end
    render json: {accounts: accounts}
  end

  def update
    if params[:type] && params[:id] && params[:field]
      model = params[:type].constantize
      object = model.find(params[:id])
      # only allow changes for admin account users and admins managing their own users
      if @current_user.account.is_admin_account? || (params[:type] == "User" && object.account == @current_user.account)  
        if params[:value]
          object.update(params[:field] => params[:value])
        else
          object.toggle!(params[:field])
        end
      end
      render json: {account: object}
    else
      render :json => { :errors => "Could not update account" }, :status => 400
    end
  end

  def create_user
    if params[:email] && params[:account_id]
      account = Account.find(params[:account_id])
      # only allow changes for admin account users and admins managing their own users
      if @current_user.account.is_admin_account? || account == @current_user.account
        user = account.users.create(email: params[:email], password: SecureRandom.hex(8))
        EmailWorker.perform_async(:invite_user, user.id)
      end
    end

    if !user || user.errors.any?
      errors = user ? user.errors.full_messages.join(", ") : "Could not invite user"
      render json: { errors:  errors}, status: 400
    else
      render json: { user: user }
    end
  end

  def create_account
    if params[:name]
      # only allow changes for admin account users and admins managing their own users
      if @current_user.account.is_admin_account?
        account = Account.create(name: params[:name])
        account.can_view_support_desk = false
        account.can_view_ad_spend = true
        account.can_view_sdks = true
        account.can_view_storewide_sdks = true
        account.can_view_exports = false
        account.can_view_ios_live_scan = true
        account.save
      end
    end

    if !account || account.errors.any?
      errors = account ? account.errors.full_messages.join(", ") : "Could not create account"
      render json: { errors:  errors}, status: 400
    else
      render json: { account: account }
    end
  end
end