class PackageSearchService

  class << self

    def android_by_app_id
      AndroidApp.where('newest_apk_snapshot_id IS NOT NULL AND taken_down IS NULL').find_each.with_index do |app, index|
        li "App: #{index}"

        PackageSearchService.perform_async(app.id)
      end
    end

  end
  
end