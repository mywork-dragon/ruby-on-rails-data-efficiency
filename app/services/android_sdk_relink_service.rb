# Relink the regexes of previous 

class AndroidSdkRelinkService

  class << self

    def run

      prod = Rails.env.production?

      if prod
        batch = Sidekiq::Batch.new
        batch.description = "Relink Android Apps" 
        batch.on(:complete, 'AndroidSdkRelinkService#on_complete_run')
      end

      AndroidApp.find_in_batches(batch_size: 10000).with_index do |batch, index|
        li "App #{index*10000}"

        args = batch.map{ |android_app| [android_app.id] }

        if prod
          Sidekiq::Client.push_bulk('class' => AndroidSdkRelinkWorker, 'args' => args)
        else
          args.each do |arg|
            AndroidSdkRelinkWorker.new.perform(*arg)
          end
        end
      end

    end

    # Seed with dummy data
    # @author Jason Lew
    def seed
      raise 'You need to be in dev' unless Rails.env.development?

      aa = AndroidApp.create!(app_identifier: 'com.fakeassthing.whatever')

      apk_ss = ApkSnapshot.create(status: :success, scan_status: :scan_success)

      aa.apk_snapshots << apk_ss

      aa.newest_apk_snapshot = apk_ss
      aa.save!

      xamarin_android_sdk = AndroidSdk.create!(name: 'Xamarin', kind: :native)
      SdkRegex.create!(regex: 'xamarin', android_sdk_id: xamarin_android_sdk.id)

      ionic_android_sdk = AndroidSdk.create!(name: 'Ionic', kind: :native)
      DllRegex.create!(regex: /Ionic\./, android_sdk_id: ionic_android_sdk.id)

      ac_android_sdk = AndroidSdk.create!(name: 'Appcelerator (JS)', kind: :js)
      JsTagRegex.create!(regex: /appcelerator/i, android_sdk_id: ac_android_sdk.id)


      sdk_package_packages = %w(com.xamarin.blah com.bunchofcrap)
      sdk_package_packages.each do |package|
        sdk_package = SdkPackage.create!(package: package)
        SdkPackagesApkSnapshot.create!(sdk_package_id: sdk_package.id, apk_snapshot_id: apk_ss.id)
      end

      sdk_dll_names = %w(Ionic.dll Fakie.dll)
      sdk_dll_names.each do |name|
        sdk_dll = SdkDll.create!(name: name)
        ApkSnapshotsSdkDll.create!(sdk_dll_id: sdk_dll.id, apk_snapshot_id: apk_ss.id)
      end

      sdk_js_tag_names = %w(Appcelerator.js thisdoesnothing.js)
      sdk_js_tag_names.each do |name|
        sdk_js_tag = SdkJsTag.create!(name: name)
        ApkSnapshotsSdkJsTag.create!(sdk_js_tag_id: sdk_js_tag.id, apk_snapshot_id: apk_ss.id)
      end

    end

  end

  def on_complete_run(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'AndroidSdkRelinkService completed.')
  end

end