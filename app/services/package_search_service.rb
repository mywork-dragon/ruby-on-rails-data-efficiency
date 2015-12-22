class PackageSearchService

  class << self

    def run(n = 200)
      # SdkScraper.all.each{ |x| x.concurrent_apk_downloads = 0; x.save }
      # AndroidApp.where(newest_apk_snapshot_id: nil).joins(:newest_apk_snapshot).where('apk_snapshots.scan_version = ?',1).limit(n).each.with_index do |app, index|
      AndroidApp.where.not(newest_apk_snapshot_id: nil).limit(n).each.with_index do |app, index|
        puts index if index % 1e3 == 0
        PackageSearchServiceWorker.perform_async(app.id)
      end
    end

    def android_by_app_id(ids)
      AndroidApp.where(id: ids).each do |app|
        PackageSearchServiceWorker.perform_async(app.id)
      end
    end

    def run_local(n)
      AndroidApp.limit(n).each do |app|
        PackageSearchServiceWorker.new.perform(app.id)
      end
    end

  end

end