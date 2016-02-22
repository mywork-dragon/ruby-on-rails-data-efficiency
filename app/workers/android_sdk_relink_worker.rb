class AndroidSdkRelinkWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :sdk

  def perform(android_app_id)
    android_app = AndroidApp.find(android_app_id)
    apk_ss = android_app.newest_apk_snapshot
    return if apk_ss.blank?

    link_packages(apk_ss)
    link_dlls(apk_ss)
    link_js_tags(apk_ss)

    true
  end

  def link_packages(apk_ss)
    sdk_packages = apk_ss.sdk_packages

    sdk_packages.each do |sdk_package|
      package = sdk_package.package

      SdkRegex.find_each do |sdk_regex|
        regex_s = sdk_regex.regex
        next if regex_s.blank?
        regex = Regexp.new(regex_s)

        if regex.match(package)
          AndroidSdksApkSnapshot.create!(apk_snapshot_id: apk_ss.id, android_sdk_id: sdk_regex.android_sdk_id)
        end
      end
    end
  end

  def link_dlls(apk_ss)
    sdk_dlls = apk_ss.sdk_dlls

    sdk_dlls.each do |sdk_dll|
      name = sdk_dll.name

      DllRegex.find_each do |dll_regex|
        regex = dll_regex.regex
        next if regex.blank?

        if regex.match(name)
          AndroidSdksApkSnapshot.create!(apk_snapshot_id: apk_ss.id, android_sdk_id: dll_regex.android_sdk_id)
        end
      end
    end
  end

  def link_js_tags(apk_ss)
    sdk_js_tags = apk_ss.sdk_js_tags

    sdk_js_tags.each do |sdk_js_tag|
      name = sdk_js_tag.name

      JsTagRegex.find_each do |js_tag_regex|
        regex = js_tag_regex.regex
        next if regex.blank?

        if regex.match(name)
          AndroidSdksApkSnapshot.create!(apk_snapshot_id: apk_ss.id, android_sdk_id: js_tag_regex.android_sdk_id)
        end
      end
    end
  end
  
end