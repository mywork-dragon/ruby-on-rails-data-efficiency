class AdobeDomainsReport

  # This class produces the domains report for Adobe.
  # It pulls the input data and push the output data to AWS S3.

  ######################## INSTRUCTIONS ################################

  ## TO RUN IT

  # Place the input data in the S3_INPUT_BUCKET url.
  # From terminal you can use:
  # $ awslogin
  # $ aws s3 cp s3://mightysignal-customer-reports/adobe/input/ios_sdks.csv ./
  # $ aws s3 cp s3://mightysignal-customer-reports/adobe/input/android_sdks.csv ./
  # $ aws s3 cp s3://mightysignal-customer-reports/adobe/input/top-1m.csv ./
  # $ aws s3 cp s3://mightysignal-customer-reports/adobe/input/domains.csv ./

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

  # Upload the produced files (adobe_apps_ios.csv, adobe_apps_android.csv, adobe_domain_mapping.csv to the S3_OUTPUT_BUCKET url (not automated yet)
  # $ aws s3 cp adobe.zip s3://mightysignal-customer-reports/adobe/output/

  class << self
    def apps_hot_store
      @apps_hot_store ||= AppHotStore.new
    end

    def sdks_to_track
      @sdks_to_track ||= []
    end
    
    def app_ids
      @app_ids ||= []
    end
    
    def domains
      @domains ||= File.read('top-1m.csv').split("\n").map{ |i| i.split(",").last }
    end
    
    
    ####
    # Take the domains file and platform and generate the report. 
    # This will output 3 files: adobe_apps_ios.csv, adobe_apps_android.csv, 
    # and adobe_domain_mapping.csv
    # generate('domains.csv', 'ios', 0, 600000)
    ###
    
    def generate(domains_file_name, platform, bottom, top)
      sdks_data = platform == 'ios' ? CSV.read("ios_sdks.csv") : CSV.read("android_sdks.csv")
      get_sdk_list(sdks_data)
      
      p "Reading domain file"
      domains = CSV.read(domains_file_name).flatten.uniq[bottom..top]

      CSV.open("adobe_apps_#{platform}_#{bottom}_#{top}.csv", "w") do |csv|  
        csv << headers_row()  
        i = 0
        domains.each do |domain|
          d = UrlHelper.url_with_domain_only(domain)
          i += 1
          percent = ((i.to_f / domains.count) * 100).round(0)
          puts "#{i} #{domain} #{percent}%"
          publisher_id = get_best_publisher(d, platform)
          if publisher_id > 0
            publisher = platform == 'ios' ? IosDeveloper.find(publisher_id) : AndroidDeveloper.find(publisher_id)
            p "Apps found #{publisher.apps.length}"
            publisher.apps.each do |app_data|
              app = apps_hot_store.read(platform, app_data.id)
              next if (app.nil? || app.empty? || app['all_version_ratings_count'].to_i < 1000 || app_ids.include?(app_data.id.to_i)) 
              app_ids << app_data.id.to_i
              sdks_used = get_used_sdks(app)
              app['app_identifier'] = app_data.app_identifier
              csv << produce_csv_line(publisher, app, sdks_used, platform, domain)
            end
          else
            p "Skipped #{i}"
            csv << [domain]
          end
        end
      end  
    end
    
    ####
    # Choose the best match between the given domain
    # and the multiple publishers related to it:
    # Algorithm: Shortest domain that passes inclusion test
    ####
    
    def get_best_publisher(domain, platform)
      publisher_id = handle_major_publishers(domain, platform)
      return publisher_id if publisher_id > 0
      
      domain_co = domain.split('.').first
      developer_ids = platform == 'ios' ? Website.where(domain: domain).map{ |w| w.ios_developer_ids }.flatten.uniq : Website.where(domain: domain).map{ |w| w.android_developer_ids }.flatten.uniq
      devs = []
      developer_ids.each do |id|
        h = Hash.new
        developer = platform == 'ios' ? IosDeveloper.find(id) : AndroidDeveloper.find(id)
        h['id'] = id
        h['company'] = clean(developer.name)
        h['company_length'] = h['company'].size
        h['domain'] = domain
        h['rank'] = domains.index(domain) || 1000000
        h['test'] = inclusion_test(domain_co, h['company'])
        devs << h
      end
      #find devs where test is true and pick the lowest rank and then shortest company name
      winner = devs.select{ |d| d['test'] == true }.sort_by{ |v| [v['rank'],v['company_length']] }.first
      if winner.present?
        developer = platform == 'ios' ? IosDeveloper.find(winner['id']) : AndroidDeveloper.find(winner['id'])
        publisher_id = developer.id
      end
      publisher_id
    rescue
      0
    end
    
    ####
    #
    # String comparison functions
    #
    ####
    
    def clean(string)
      clean_company(string).to_s.downcase.gsub(/[\.\s]/, '')
    end
  
    def inclusion_test(domain_co, developer_name)
      sort = [clean(domain_co), clean(developer_name)].sort_by(&:length)
      short = sort.first
      long = sort.last
      if short.to_s.length >= 3
        long.include? short
      else
        false
      end
    end
    
    def clean_company(company)
      company.to_s
      .gsub(/[\u0080-\u00ff]/, '') # remove non-UTF i think?
      .gsub(/\(.*\)/i, '') # remove parentheses and all content between
      .gsub(/,?\s+(pty ltd|pte ltd|ltd|llc|l.l.c|inc|lp|llp|corporation|associates|holdings|corporate)(\.|\s)?/i, '') # remove common company endings
      .gsub(/[^0-9a-z:.\/\s-]/i, '')
      .gsub('...', '')
      .gsub(/\.+/i, '.')
      .sub(/^https?\:?\/\//i, '')
      .sub(/^www./i, '')
      .gsub(/\s+/, ' ')
      .gsub('--', '')
      .downcase
      .truncate(100, separator: ' ', omission: '')
      .encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      .squish
    end 
    
    def handle_major_publishers(domain, platform)
      publisher_id = false
      h = Hash.new
      h['facebook.com'] = {'ios': 37304, 'android': 55 }
      h['instagram.com'] = {'ios': 37304, 'android': 55 }
      h['google.com'] = {'ios': 6864, 'android': 928995 }
      h['gmail.com'] = {'ios': 6864, 'android': 928995 }
      h['youtube.com'] = {'ios': 6864, 'android': 928995 }
      h.dig(domain, platform.to_sym).to_i
    end
    
    ####
    # Given the Hotstore output this generates an array
    # to pass to the open CSV block
    ####
    
    def produce_csv_line(publisher, app, sdks_used, platform, domain)
      line = [domain]
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
        line << ( 'https://itunes.apple.com/developer/id' + app['app_identifier'].to_s )
      else
        line << ( 'https://play.google.com/store/apps/details?id=' + app['app_identifier'].to_s )
      end
      line << app['original_release_date']
      line << app['last_updated']
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
      sdks_used.each do |sdks|
        line << sdks[:is_used]
      end

      line
    rescue => e
      puts e
      line
    end

    ####
    # Takes the raw Hotstore hash and adds a key and value for is_used
    ####
    
    def get_used_sdks(app)
      return if app['sdk_activity'].nil? || app['sdk_activity'].empty?
      sdks_to_track.each do |sdk_data|
        sdk_found = app['sdk_activity'].find{ |sdkact| sdkact['id'] == sdk_data[:id].to_i && sdkact['installed'] }.present?
        sdk_data[:is_used] = sdk_found
      end
    end
    
    ####
    # Converts the sdks CSV file into a hash
    ####

    def get_sdk_list(sdks_data)
      sdks_data.each do |row|
        hash_data = {id: row[0], name: row[1], is_used: false}
        sdks_to_track << hash_data
      end
    end
    
    ####
    # Writes the header row
    ####

    def headers_row
      headers = [
        'Domain',
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
        'Version',
        'Number of SDKs',
        'Mobile Priority',
        'User Base',
        'Ratings Per Day for Current Release',
        'Downloads'
      ]
      sdks_to_track.each do |sdk|
        headers << sdk[:name]
      end

      headers
    end

  end
end
