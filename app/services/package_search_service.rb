class PackageSearchService

  class << self

    def android_by_app_id(ids)
      AndroidApp.where(id: ids).each do |app|
        PackageSearchServiceWorker.perform_async(app.id)
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
  



ApkSnapshot.where('status = 1 AND updated_at > ?', 1.day.ago).count