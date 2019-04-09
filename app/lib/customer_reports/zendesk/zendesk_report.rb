class ZendeskReport

  # This class produces the domains report for Zendesk.
  # It pulls the input data and push the output data to AWS S3.
  #
  # Download the zendesk-mapping.csv file 
  # $ aws s3 cp s3://mightysignal-customer-reports/zendesk/input/zendesk-mapping.csv zendesk-mapping.csv
  #
  # To generate the report, use the Rails runner from the container bash
  # $ rails runner -e production "ZendeskReport.generate('zendesk-mapping.csv', 'ios')"
  #
  # Compress before uploading
  # zip f1000.zip f1000-*
  #
  # Upload the produced files to the S3_OUTPUT_BUCKET url (not automated yet)
  # $ aws s3 cp f1000.zip s3://mightysignal-customer-reports/zendesk/output/

  class << self

    def apps_hot_store
      @apps_hot_store ||= AppHotStore.new
    end
    
    def get_publisher_ids(domains_file_name, platform)
      p "Reading domain file"
      domains = []
      CSV.foreach(domains_file_name, headers: true) {|row| domains << row['host_mapping'].split(".").drop(1).join(".") if row['host_mapping'].present? }
      p "Plucking domains from db"
      domain_data = DomainDatum.pluck(:domain)
      p "Finding intersection"
      intersect = domains & domain_data
      p "Converting domain_datum IDs to website IDs"
      intersect_website_ids = intersect.map{ |d| DomainDatum.find_by_domain(d).website_ids }.flatten.uniq
      if platform == 'ios'
        publisher_ids = intersect_website_ids.map{ |id| Website.find(id).ios_developer_ids }.flatten.uniq
      else
        publisher_ids = intersect_website_ids.map{ |id| Website.find(id).android_developer_ids }.flatten.uniq
      end
      p "Making domain mapping file"
      CSV.open("zendesk-mapping.csv", "w") do |csv| 
        csv << ['id', 'domain']
        intersect.each do |d|
          intersect_website_ids = DomainDatum.find_by_domain(d).website_ids
          intersect_website_ids.each do |id|
            csv << [id, d]
          end
        end
      end
      publisher_ids_table
    end
    
    def get_f1000_publisher_ids(platform)
      domains = []
      p "Converting domain_datum IDs to website IDs"
      website_ids = DomainDatum.where.not(fortune_1000_rank: nil).map{ |d| d.website_ids }.flatten.uniq
      if platform == 'ios'
        publisher_ids = website_ids.map{ |id| Website.find(id).ios_developer_ids }.flatten.uniq
      else
        publisher_ids = website_ids.map{ |id| Website.find(id).android_developer_ids }.flatten.uniq
      end
      publisher_ids
    end

    def generate
      #publisher_ids_table = get_publisher_ids(domains_file_name) # if it needs to be generated
      publisher_ids_table = CSV.read("zendesk-mapping.csv", headers: true)
      CSV.open("zendesk-android-apps.csv", "w") { |f| f << app_headers_row }
      CSV.open("zendesk-ios-apps.csv", "w") { |f| f << app_headers_row }
      CSV.open("zendesk-android-sdks.csv", "w") { |f| f << sdk_headers_row }
      CSV.open("zendesk-ios-sdks.csv", "w") { |f| f << sdk_headers_row }
      i = 0
      publisher_ids_table.each do |row|
        i += 1
        p "Running #{i}"
        if row['android_publisher_id']
          p "Doing android publisher #{row['android_publisher_id']}"
          publisher = AndroidDeveloper.find(row['android_publisher_id'])
          publisher.apps.each do |app_data|
            p "Doing app #{app_data.id}"
            app = apps_hot_store.read('android', app_data.id)
            next if (app.nil? || app.empty?) 
            CSV.open("zendesk-android-apps.csv", "a+") { |f| f << produce_app_line(row, publisher, app, app_data) }
            if app['sdk_activity'].present?
              CSV.open("zendesk-android-sdks.csv", "a+") do |csv|
                app['sdk_activity'].each do |sdk|
                  csv << produce_sdk_line(row, sdk)
                end
              end
            end
          end
        end
        
        if row['ios_publisher_id']
          p "Doing ios publisher #{row['ios_publisher_id']}"
          publisher = IosDeveloper.find(row['ios_publisher_id'])
          publisher.apps.each do |app_data|
            p "Doing app #{app_data.id}"
            app = apps_hot_store.read('ios', app_data.id)
            next if (app.nil? || app.empty?) 
            CSV.open("zendesk-ios-apps.csv", "a+") { |f| f << produce_app_line(row, publisher, app, app_data) }
            if app['sdk_activity'].present?
              CSV.open("zendesk-ios-sdks.csv", "a+") do |csv|
                app['sdk_activity'].each do |sdk|
                  csv << produce_sdk_line(row, sdk)
                end
              end
            end
          end
        end
      end

      p "Done generating files"
    end
    
    def generate_f1000(platform)
      publisher_ids = get_f1000_publisher_ids(platform)
      
      if platform == 'ios'
        CSV.open("f1000-ios-apps.csv", "w") { |f| f << app_headers_row }
        CSV.open("f1000-ios-sdks.csv", "w") { |f| f << sdk_headers_row }
      else
        CSV.open("f1000-android-apps.csv", "w") { |f| f << app_headers_row }
        CSV.open("f1000-android-sdks.csv", "w") { |f| f << sdk_headers_row }
      end
      
      i = 0
      publisher_ids.each do |id|
        row = nil
        i += 1
        p "Running #{i}"
        if platform == 'ios'
          publisher = IosDeveloper.find(id)
          publisher.apps.each do |app_data|
            p "Doing app #{app_data.id}"
            app = apps_hot_store.read('ios', app_data.id)
            next if (app.nil? || app.empty?) 
            CSV.open("f1000-ios-apps.csv", "a+") { |f| f << produce_app_line(row, publisher, app, app_data) }
            if app['sdk_activity'].present?
              CSV.open("f1000-ios-sdks.csv", "a+") do |csv|
                app['sdk_activity'].each do |sdk|
                  csv << produce_sdk_line(row, sdk)
                end
              end
            end
          end
        else
          publisher = AndroidDeveloper.find(id)
          publisher.apps.each do |app_data|
            p "Doing app #{app_data.id}"
            app = apps_hot_store.read('android', app_data.id)
            next if (app.nil? || app.empty?) 
            CSV.open("f1000-android-apps.csv", "a+") { |f| f << produce_app_line(row, publisher, app, app_data) }
            if app['sdk_activity'].present?
              CSV.open("f1000-android-sdks.csv", "a+") do |csv|
                app['sdk_activity'].each do |sdk|
                  csv << produce_sdk_line(row, sdk)
                end
              end
            end
          end
        end
      end

      p "Done generating files"
    end
    
    def produce_sdk_line(row, sdk)
      zendesk_id = row.present? ? row['zendesk_id'] : ''
      line = []
      line << zendesk_id
      line << sdk['id']
      line << sdk['name']
      line << sdk['id']
      line << sdk['categories'].nil? ? "" : sdk['categories'].join("|")
      line << sdk['first_seen_date']
      line << sdk['last_seen_date']
      line << sdk['installed']
      line
    end
    
    def sdk_headers_row
      headers = [
        'Zendesk ID',
        'App ID',
        'SDK Name',
        'SDK ID',
        'Categories',
        'First Seen Date',
        'Last Seen Date',
        'Installed',
      ]

      headers
    end
    
    def produce_app_line(row, publisher, app, app_data)
      zendesk_id = row.present? ? row['zendesk_id'] : ''
      line = []
      line << zendesk_id
      line << app['id']
      line << app['platform']
      line << app_data.app_identifier
      line << app['first_scanned_date']
      line << app['first_scraped']
      line << app['name']
      line << app['all_version_ratings_count']
      line << app['all_version_rating']
      line << app['current_version_ratings_count']
      line << app['current_version_rating']
      line << app['price']
      line << app['in_app_purchases']
      if app['categories'].nil? || app['categories'].empty?
        line << ""
      else
        line << app['categories'].map{ |c| c['name'] }.join("|")
      end
      line << publisher.id
      line << publisher.name
      line << publisher.try(:fortune_1000_rank)
      if app['platform'] == 'ios'
        line << ( 'https://itunes.apple.com/app/id' + app_data.app_identifier.to_s )
      else
        line << ( 'https://play.google.com/store/apps/details?id=' + app_data.app_identifier.to_s )
      end
      line << app_data.last_updated
      line << app['current_version']
      if app['sdk_activity'].nil? || app['sdk_activity'].empty?
        line << ""
      else
        line << app['sdk_activity'].select{|sdk| sdk['installed']}.size
      end
      line << app['mobile_priority']
      line << app['user_base']
      line << (app['ratings_by_country'] ? app['ratings_by_country'].sum {|rt| rt['ratings_per_day_current_release']} : 0)
      if app['platform'] == 'ios'
        line << ""
      else
        line << app['downloads_min']
      end
      if app['newcomers'].present?
        line << app['newcomers'].min_by{|k| k['rank'] }['rank']
        line << app['newcomers'].min_by{|k| k['rank'] }['category']
        line << app['newcomers'].min_by{|k| Date.parse(k['date']) }['rank']
        line << app['newcomers'].min_by{|k| Date.parse(k['date']) }['category']
      else
        line << "" 
        line << ""
        line << ""
        line << ""
      end
      if app['rankings'].andand['charts'].present?
        line << app['rankings']['charts'].min_by{|k| k['rank'] }['rank']
        line << app['rankings']['charts'].min_by{|k| k['rank'] }.slice('category', 'ranking_type').values.join(" ")
        line << app['rankings']['charts'].max_by{|k| k['rank'] }['rank']
        line << app['rankings']['charts'].max_by{|k| k['rank'] }.slice('category', 'ranking_type').values.join(" ")
        line << app['rankings']['charts'].max_by{|k| k['weekly_change'].to_i }['weekly_change']
        line << app['rankings']['charts'].max_by{|k| k['weekly_change'].to_i }.slice('category', 'ranking_type').values.join(" ")
        line << app['rankings']['charts'].max_by{|k| k['monthly_change'].to_i }['weekly_change']
        line << app['rankings']['charts'].max_by{|k| k['monthly_change'].to_i }.slice('category', 'ranking_type').values.join(" ")
      else
        line << "" 
        line << ""
        line << ""
        line << ""
      end
      line << app_data.first_seen_ads_date
      line << app_data.last_seen_ads_date
      line << app_data.ad_attribution_sdks.map{ |sdk| sdk['name'] }.join("|")
      line
    rescue => e
      line
    end

    def app_headers_row
      headers = [
        'Zendesk ID',
        'App ID',
        'Platform',
        'App Identifier',
        'First Scanned Date',
        'Release Date',
        'App Name',
        'Rating Count (All Versions)',
        'Rating Avg (All Versions)',
        'Rating Count (Current Version)',
        'Rating Avg (Current Version)',
        'Price',
        'In-App Purchases',
        'Category',
        'Publisher ID',
        'Publisher Name',
        'Publisher Fortune Rank',
        'App Store Link',
        'Last Updated Date',
        'Version',
        'Number of SDKs',
        'Mobile Priority',
        'User Base',
        'Ratings Per Day for Current Release',
        'Downloads',
        'Least Newcomer Value',
        'Least Newcomer Chart',
        'Earliest Newcomer Value',
        'Earliest Newcomer Chart',
        'Max Rank Value',
        'Max Rank Chart',
        'Min Rank Value',
        'Min Rank Chart',
        'Min Weekly Change Value',
        'Min Weekly Change Chart',
        'Min Monthly Change Value',
        'Min Monthly Change Chart',
        'First Seen Ads',
        'Last Seen Ads',
        'Ad Attribution SDKs',
      ]

      headers
    end

  end
end
