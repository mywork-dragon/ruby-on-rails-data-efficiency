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

      AndroidApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "App #{index*1000}"

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

      aa = AndroidApp.create!(app_identifer: 'com.fakeassthing.whatever')

      apk_ss = ApkSnapshot.create!

      aa.newest_apk_snapshot = apk_ss
      aa.save!

      sdk_package_packages = %w(com.xamarin.blah com.gamedonia.yippee com.bunchofcrap)
      sdk_package_packages.each do |package|
        sdk_package = SdkPackage.create!(package: package)
        SdkPackagesApkSnapshot.create!(sdk_package_id: sdk_package.id, apk_snapshot_id: apk_ss.id)
      end

      sdk_dll_names = %w(Ionic.dll GameUpSdk.dll Fakie.dll)
      sdk_dll_names.each do |name|
        sdk_dll = SdkDll.create!(name: name)
        ApkSnapshotsSdkDll.create!(sdk_dll_id: sdk_dll.id, apk_snapshot_id: apk_ss.id)
      end

      sdk_js_tag_names = %w(Appcelerator.js bootstrap.min.js thisdoesnothing.js)
      sdk_js_tag_names.each do |name|
        sdk_js_tag = SdkJsTag.create!(name: name)
        ApkSnapshotsSdkJsTag!(sdk_js_tag_id: sdk_js_tag.id, apk_snapshot_id: apk_ss.id)
      end

    end

  end

  def on_complete_run(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'AndroidSdkRelinkService completed.')
  end

end