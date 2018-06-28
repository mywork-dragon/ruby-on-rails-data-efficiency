class IosDownloadController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  before_action :set_current_user, :authenticate_request, :authenticate_admin_account

  def update
    cd = ClassDump.find(params.fetch(:varys_cd_id))
    snapshot = cd.ipa_snapshot
    ap body = JSON.parse(request.body.read)

    # register results
    account = AppleAccount.find_by_email(body['itunes_user']) if body['itunes_user']
    device_id = IosDevice.find_by_apple_account_id(account.id) if account
    success = !!body['success']

    cd.update!(
      apple_account_id: account.try(:id),
      ios_device_id: device_id,
      success: success,
      dump_success: success,
      complete: true
    )

    snapshot.update!(
      download_status: :complete,
      success: success
    )

    # queue for classification
    classification_worker = if body['classification_priority'] == 'high'
                              IosClassificationServiceWorker
                            else
                              IosMassClassificationServiceWorker
                            end
    if success
      classification_worker.perform_async(snapshot.id)
    end

    render json: {'status' => 'ok'}
  end
end
