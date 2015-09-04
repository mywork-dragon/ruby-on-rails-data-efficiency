class PackageSearchService

  class << self

    def run

      def android_by_app_id
        AndroidApp.where('newest_apk_snapshot_id IS NOT NULL AND taken_down IS NULL').find_each.with_index do |batch, index|
          li "Batch #{index}"
          android_app_ids = batch.map{|aa| aa.id}.select{ |aa| aa.present?}

          BusinessEntityAndroidServiceWorker.perform_async(android_app_ids)
        end
      end

    end

  end
  
end