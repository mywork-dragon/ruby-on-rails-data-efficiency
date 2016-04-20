class ActivityWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :sdk

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def log_ios_sdks(app_id)
    app = IosApp.find(app_id)
    snapshots = app.ipa_snapshots.where(scan_status: IpaSnapshot.scan_statuses[:scanned]).order([:good_as_of_date, :id]).to_a

    return if snapshots.empty?

    snapshots.reverse!
    snapshots.each_with_index do |snapshot,i|
      next_snapshot = snapshots[i+1]
      snapshot_sdks = snapshot.ios_sdks.to_a
      next_snapshot_sdks = next_snapshot.try(:ios_sdks).try(:to_a) || []
      (snapshot_sdks - next_snapshot_sdks).uniq.each do |sdk|
        if (sdk.cluster & next_snapshot_sdks).empty?
          sdk.cluster.each do |cluster_sdk|
            #puts "Add install cluster #{app.name} #{cluster_sdk.name}\n"
            Activity.log_activity(:install, snapshot.first_valid_date, app, cluster_sdk)
          end
        else
          sdk.cluster.each do |cluster_sdk|
            #puts "Remove install cluster #{app.name} #{cluster_sdk.name}\n"
            Activity.remove_activity(:install, snapshot.first_valid_date, app, cluster_sdk)
          end
        end
      end
      (next_snapshot_sdks - snapshot_sdks).uniq.each do |sdk|
        if (sdk.cluster & snapshot_sdks).empty?
          sdk.cluster.each do |cluster_sdk|
            #puts "Add uninstall cluster #{app.name} #{cluster_sdk.name}\n"
            Activity.log_activity(:uninstall, snapshot.first_valid_date, app, cluster_sdk)
          end
        else
          sdk.cluster.each do |cluster_sdk|
            #puts "Remove uninstall cluster #{app.name} #{cluster_sdk.name}\n"
            Activity.remove_activity(:uninstall, snapshot.first_valid_date, app, cluster_sdk)
          end
        end
      end
    end  
  end

  def log_android_sdks(app_id)
    app = AndroidApp.find(app_id)
    snapshots = app.apk_snapshots.where(scan_status: ApkSnapshot.scan_statuses[:scan_success]).order([:good_as_of_date, :id]).to_a

    return if snapshots.empty?

    snapshots.reverse!
    snapshots.each_with_index do |snapshot,i|
      next_snapshot = snapshots[i+1]
      snapshot_sdks = snapshot.android_sdks.to_a
      next_snapshot_sdks = if next_snapshot.present?
        next_snapshot.android_sdks.to_a
      else
        []
      end
      (snapshot_sdks - next_snapshot_sdks).uniq.each do |sdk|
        if (sdk.cluster & next_snapshot_sdks).empty?
          sdk.cluster.each do |cluster_sdk|
            puts "Add install cluster #{app.name} #{cluster_sdk.name}\n"
            Activity.log_activity(:install, snapshot.first_valid_date, app, cluster_sdk)
          end
        else
          sdk.cluster.each do |cluster_sdk|
            puts "Remove install cluster #{app.name} #{cluster_sdk.name}\n"
            Activity.remove_activity(:install, snapshot.first_valid_date, app, cluster_sdk)
          end
        end
      end
      (next_snapshot_sdks - snapshot_sdks).uniq.each do |sdk|
        if (sdk.cluster & snapshot_sdks).empty?
          sdk.cluster.each do |cluster_sdk|
            puts "Add uninstall cluster #{app.name} #{cluster_sdk.name}\n"
            Activity.log_activity(:uninstall, snapshot.first_valid_date, app, cluster_sdk)
          end
        else
          sdk.cluster.each do |cluster_sdk|
            puts "Remove uninstall cluster #{app.name} #{cluster_sdk.name}\n"
            Activity.remove_activity(:uninstall, snapshot.first_valid_date, app, cluster_sdk)
          end
        end
      end
    end  
  end
end