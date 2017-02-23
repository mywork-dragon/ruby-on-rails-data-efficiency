class JobsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_admin_account

  def trigger_android_reclassification
    AndroidReclassificationWorker.perform_async()
    render json: { success: true }, status: 200
  end

end
