class JobsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_admin_account

  def trigger_android_reclassification
    AndroidReclassificationWorker.perform_async()
    render json: { success: true }, status: 200
  end

  def trigger_ios_reclassification
    classdump_ids = params.fetch('classdump_ids')
    IosReclassificationService.reclassify_classdump_ids(classdump_ids)
    render json: { success: true }, status: 200
  end

  rescue_from KeyError do |exception|
    render json: { error: exception.message }, status: 400
  end

end
