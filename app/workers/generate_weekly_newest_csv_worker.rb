class GenerateWeeklyNewestCsvWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :scraper_master

  def perform
    epf_full_feed_last = EpfFullFeed.last
      file_path = "/home/deploy/#{epf_full_feed_last.name}_weekly_newest.csv"
    
      newest_date = IosAppEpfSnapshot.where(epf_full_feed: epf_full_feed_last).order('itunes_release_date DESC').limit(1).first.itunes_release_date
      week_before_newest = newest_date - 6.days
    
      CSV.open(file_path, "w") do |csv|
        # column_names = IosAppEpfSnapshot.column_names
        column_names = IosAppEpfSnapshot.column_names - ['itunes_release_date'] #use release date from IosApp instead now (until Apple fixed their stuff)
        csv << column_names + ['itunes_release_date', 'Category', 'User Base', 'Average Rating', 'Number of Ratings', 'MightySignal ID']
        #IosAppEpfSnapshot.where(epf_full_feed: epf_full_feed_last, itunes_release_date:  week_before_newest..newest_date).order('itunes_release_date DESC').each do |ios_app_epf_ss| 
        IosApp.where(released:  week_before_newest..newest_date).order('released DESC').each do |ios_app|

          ios_app_epf_ss = IosAppEpfSnapshot.where(epf_full_feed: epf_full_feed_last, application_id: ios_app.app_identifier).first

          row = if ios_app_epf_ss.blank?
                  Array.new(column_names.count)
                else
                  ios_app_epf_ss.attributes.values_at(*column_names)            
                end

          # row = ios_app_epf_ss.attributes.values_at(*column_names)
        
          #ios_app = IosApp.find_by_app_identifier(ios_app_epf_ss.application_id)
        
          if ios_app && (ios_app_ss = ios_app.newest_ios_app_snapshot)
          
            released = ios_app.released

            category = ios_app_ss.ios_app_categories.first.name
            category = IosAppCategoriesSnapshot.where(ios_app_snapshot_id: ios_app_ss.id, kind: '0').first.ios_app_category.name

            user_base = ios_app.user_base
          
            average_rating = ios_app_ss.ratings_current_stars
          
            number_of_ratings = ios_app_ss.ratings_current_count

            mighty_signal_id = ios_app.id
          
            row += [released, category, user_base, average_rating, number_of_ratings, mighty_signal_id]
          end

          csv << row
          
        end
      end
    
      Slackiq.message("EPF CSV has been generated! Path: #{file_path}", webhook_name: :main)

      file_path
  end
  
end