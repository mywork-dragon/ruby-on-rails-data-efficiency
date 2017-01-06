class FbAccountController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :authenticate_admin

  class BadRequest < RuntimeError; end
  class NotAvailable < RuntimeError; end

  def reserve
    account_purpose = params['purpose']
    raise BadRequest, 'invalid purpose'  if account_purpose.nil? || FbAccount.purposes[account_purpose].nil?

    account = reserve_fb_account(account_purpose)
    render json: account, status: 200
  end

  def release
    account_id = params['id'].to_i
    raise BadRequest, 'invalid or missing account id' if account_id == 0

    FbAccount.find(account_id).update!(in_use: false)

    render json: { success: true }, status: 200
  end

  def reserve_fb_account(purpose)
    account = FbAccount.transaction do
      f = FbAccount.lock.where(
        purpose: FbAccount.purposes[purpose],
        in_use: false
      ).sample

      if f
        f.in_use = true
        f.save!
      end

      f
    end

    raise NotAvailable unless account

    account
  end

  rescue_from BadRequest do |exception|
    render json: { error: exception.message }, status: 400
  end

  rescue_from NotAvailable, ActiveRecord::RecordNotFound do |exception|
    render json: { error: exception.message }, status: 404
  end
end
