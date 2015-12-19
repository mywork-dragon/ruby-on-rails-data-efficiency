class PackageSearchService

  class << self

    def run(n)
      AndroidApp.where.not(newest_apk_snapshot_id: nil).limit(n).each do |app|
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