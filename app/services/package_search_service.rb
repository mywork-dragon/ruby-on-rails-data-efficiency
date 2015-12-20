class PackageSearchService

  class << self

    def run(n = 200)
      SdkScraper.all.each{ |x| x.concurrent_apk_downloads = 0; x.save }
      # `rm /home/deploy/threads/*`

      apps = []
      # AndroidApp.where.not(newest_apk_snapshot_id: nil).limit(n).each do |app|
      AndroidApp.where.not(newest_apk_snapshot_id: nil).random(n).each do |app|
        PackageSearchServiceWorker.perform_async(app.id)
        apps << app.id
      end
      apps
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