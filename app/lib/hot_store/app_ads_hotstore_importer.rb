class AppAdsHotstoreImporter

  def initialize
    @hot_store = AppHotStore.new
    @ad_data_accessor = AdDataAccessor.new
  end

  def import_all(page_size: 1000, num_pages: nil)
    page_number = 0

    loop do 
      results, total = @ad_data_accessor.fetch_all_app_summaries(
      Account.find(1), # Use MightySignal Account
      page_size: page_size, 
      page_number: page_number)

      results.each do |app_id, summary|
        @hot_store.write_ad_summary(app_id, summary["app_identifier"], summary["platform"], summary["ad_networks"])
      end
      
      page_number += 1

      break if page_size * page_number > total
      break if num_pages && page_number >= num_pages
    end
  end

end
