class PackageSearchService

  class << self

    def android_by_app_id
      AndroidApp.where('newest_apk_snapshot_id IS NOT NULL AND taken_down IS NULL').find_each.with_index do |app, index|
        li "App: #{index}"

        PackageSearchService.perform_async(app.id)
      end
    end

    def sdks_from_snaps(n = nil)

    	snaps = n.nil? ? ApkSnapshot.where(status: 1) : ApkSnapshot.where(status: 1).limit(n)

    	snaps.each do |snap|

        next if snap.android_app.nil?

    		app_id = snap.android_app.id

    		PackageSearchServiceWorker.perform_async(app_id)

    	end

    	nil

    end

    def run_local(n)

      AndroidApp.limit(n).each do |app|
        PackageSearchServiceWorker.new.perform(app.id)
      end

    end

  end
  
end