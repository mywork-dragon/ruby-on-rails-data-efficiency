class AndroidSdksForAppService
  
  def sdks_hash
    android_app_id = params['appId']

    aa = AndroidApp.find(android_app_id)

    if aa.newest_apk_snapshot.blank?

      hash = nil

    else

      new_snap = aa.newest_apk_snapshot

    end

    if new_snap.present? && new_snap.status == "success"

      p = new_snap.android_packages.where('android_package_tag != 1')

      hash = clean_up_android_sdks(p)

    else
      hash = nil
    end

    hash
  end
  
end