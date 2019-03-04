class BugsnagReport

  # This class produces the domains report for Adobe.
  # It pulls the input data and push the output data to AWS S3.

  ######################## INSTRUCTIONS ################################

  ## TO RUN IT

  # Place the input data in the S3_INPUT_BUCKET url.
  # From terminal you can use:
  # $ awslogin
  # $ aws s3 cp local_folder/file.csv  s3://mightysignal-customer-reports/bugsnag/input/

  # ios_sdks.csv and android_sdks are csv files with the sdk ids and names, like:
  # 64, AliPaySDK
  # 46, Mixpanel
  # 
  # Note the IDs are different for iOS and Android!!
  #
  # adobe_domains.csv is a csv file with the domains names, example:
  # fr.as24.com
  # AS24.COM

  # To generate the report, use the Rails runner from the container bash
  # $ rails runner -e production "AdobeDomainsReport.generate('domains.csv', 'ios')"

  # Upload the produced files to the S3_OUTPUT_BUCKET url (not automated yet)
  # $ aws s3 cp /tmp/adobe.ios.output.csv s3://mightysignal-customer-reports/adobe/output/

  class << self
    def apps_hot_store
      @apps_hot_store ||= AppHotStore.new
    end

    def publisher_hot_store
      @publisher_hot_store ||= PublisherHotStore.new
    end

    def domain_link
      @domain_link ||= DomainLinker.new
    end

    def sdks_to_track
      @sdks_to_track ||= []
    end
    
    def app_ids
      @app_ids ||= []
    end
    
    def produce_csv_line(sdk_name, publisher, app, platform)
      developer_info = publisher.developer_info.try(:last)
      line = [sdk_name]
      line << app['id']
      line << app['name']
      line << app['all_version_ratings_count']
      line << app['all_version_rating']
      line << app['current_version_ratings_count']
      line << app['current_version_rating']
      line << app['price']
      if app['categories'].nil? || app['categories'].empty?
        line << ""
      else
        line << app['categories'].find { |cat| cat['type'] == 'primary' }.andand['name']
      end
      line << publisher.name
      if platform == 'ios'
        line << ( 'https://itunes.apple.com/developer/id' + app['id'].to_s )
      else
        line << ( 'https://play.google.com/store/apps/details?id=' + app['bundle_identifier'].to_s )
      end
      line << app['original_release_date']
      line << app['last_updated']
      line << app['in_app_purchases']
      line << app['publisher']['id']
      line << app['publisher']['name']
      line << app['publisher']['app_store_id']
      line << developer_info.try(:fortune_1000_rank).to_s
      line << publisher.website_urls.join("|")
      if platform == 'ios'
        line << ( 'https://mightysignal.com/app/app/#/app/ios/' + app['id'].to_s )
      else
        line << ( 'https://mightysignal.com/app/app/#/app/android/' + app['id'].to_s )
      end
      if platform == 'ios'
        line << ( 'https://mightysignal.com/app/app/#/publisher/ios/' + app['publisher']['id'].to_s )
      else
        line << ( 'https://mightysignal.com/app/app/#/publisher/android/' + app['publisher']['id'].to_s )
      end
      line << developer_info.try(:street_number).to_s
      line << developer_info.try(:street_name).to_s
      line << developer_info.try(:city).to_s
      line << developer_info.try(:state_code).to_s
      line << developer_info.try(:country_code).to_s
      line << developer_info.try(:postal_code).to_s
      user_base_countries = ['US', 'CN', 'GB', 'JP', 'IL', 'KR', 'FR', 'RU', 'DE', 'AU', 'BR']
      user_base_countries.each do |cc|
        detail = app['user_base_by_country'].present? ? app['user_base_by_country'].find{ |i| i['country_code'] == cc } : nil
        if detail
          line << detail['user_base']
        else
          line << ""
        end
      end
      line << app['current_version']
      if app['sdk_activity'].nil? || app['sdk_activity'].empty?
        line << ""
      else
        line << app['sdk_activity'].select{|sdk| sdk['installed']}.size
      end
      line << app['mobile_priority']
      line << app['user_base']
      line << (app['ratings_by_country'] ? app['ratings_by_country'].sum {|rt| rt['ratings_per_day_current_release']} : 0)
      if platform == 'ios'
        line << ""
      else
        line << app['downloads_min']
      end

      line
    end

    def headers_row
      headers = [
        'SDK',
        'App Id',
        'App Name',
        'Rating Count (All Versions)',
        'Rating Avg (All Versions)',
        'Rating Count (Current Version)',
        'Rating Avg (Current Version)',
        'Price',
        'Category',
        'Developer',
        'Store Link',
        'Release Date',
        'Updated Date',
        'In App Purchases',
        'MightySignal Publisher ID',
        'Publisher Name',
        'App Store Publisher ID',
        'Fortune Rank',
        'Websites',
        'MightySignal App Page',
        'MightySignal Publisher Page',
        'Street Number',
        'Street Name',
        'City',
        'State',
        'Country',
        'Postal Code',
        'User Base - US',
        'User Base - CN',
        'User Base - GB',
        'User Base - JP',
        'User Base - IL',
        'User Base - KR',
        'User Base - FR',
        'User Base - RU',
        'User Base - DE',
        'User Base - AU',
        'User Base - BR',
        'Version',
        'Number of SDKs',
        'Mobile Priority',
        'User Base',
        'Ratings Per Day for Current Release',
        'Downloads'
      ]

      headers
    end
    
    def get_current_apps(platform, id, page)
      if platform == 'android'
        sdk_id = id 
      else
        sdk_id = IosSdk.select('IFNULL(ios_sdk_links.dest_sdk_id, ios_sdks.id) as id').
                     joins('LEFT JOIN ios_sdk_links ON ios_sdk_links.source_sdk_id = ios_sdks.id').
                     where(id: id).first.id
      end
      filter_args = {
        app_filters: {"sdkFiltersAnd" => [{"id" => sdk_id, "status" => "0", "date" => "0"}]},
        page_num: page,
        page_size: 10000,
        order_by: 'desc'
      }

      filter_results = platform == 'ios' ? FilterService.filter_ios_apps(filter_args) : FilterService.filter_android_apps(filter_args)
      ids = filter_results.map { |result| result.attributes["id"] }
      apps = if ids.any?
        collection = platform == 'ios' ? IosApp.where(id: ids) : AndroidApp.where(id: ids)
        collection
      else
        []
      end

      {apps: apps, total_count: filter_results.total_count}
    end
    
    
    
    def generate(platform)
      sdks_data = platform == 'ios' ? [[641, 'Cordova'], [2567, 'React']] : [[20, 'Cordova'], [6665, 'React']]
      
      CSV.open("bugsnag_#{platform}.csv", "a") do |csv|  
        csv << headers_row()
        sdks_data.each do |item|  
          sdk_name = item[1]
          sdk_id = item[0]
          p "Processing #{sdk_name}"
          apps = get_current_apps(platform, sdk_id, 1)
          p "Apps found #{apps[:total_count]}"
          page = 10
          while apps[:apps].present?
            p "Doing page #{page}"
            apps = get_current_apps(platform, sdk_id, page)
            apps[:apps].each do |app_data|
              p "Running #{app_data.id}"
              app = apps_hot_store.read(platform, app_data.id)
              next if app.blank? 
              publisher = platform == 'ios' ? app_data.ios_developer : app_data.android_developer
              next if publisher.blank?
              csv << produce_csv_line(sdk_name, publisher, app, platform)
            end
            page += 1
          end
        end
      end  

      p "Done generating file"
    end

  end
end
