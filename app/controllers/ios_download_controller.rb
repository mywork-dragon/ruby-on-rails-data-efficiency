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

    info = {
      download_status: :complete,
      success: success
    }

    if body['date_downloaded']
      info[:good_as_of_date] = DateTime.parse(body['date_downloaded'])
    end

    snapshot.update!(info)

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

  def set_ipa_snapshot_status
    ipa_snapshot_id = ClassDump.find(params.fetch(:varys_cd_id)).ipa_snapshot_id
    ipa_snapshot = IpaSnapshot.find(ipa_snapshot_id)
    body = JSON.parse(request.body.read)
    
    ipa_snapshot.update(:download_status => body["download_status"]) unless body["download_status"].nil?
    ipa_snapshot.update(:scan_status => body["scan_status"]) unless body["scan_status"].nil?

    render json: {'status' => 'ok'}
  end
end
