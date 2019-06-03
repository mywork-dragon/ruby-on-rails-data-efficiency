class AdobeReport

  # This class produces the report for Adobe.
  # It pulls the input data and push the output data to AWS S3.

  ######################## INSTRUCTIONS ################################

  ## TO RUN IT

  # Place the input data in the S3_INPUT_BUCKET url.
  # From terminal you can use:
  # $ awslogin
  # $ aws s3 cp local_folder/file.csv  s3://mightysignal-customer-reports/adobe/input/

  # Make sure the file matches the pattern for the parser version, ex:
  # v1 input file format is a csv with data formatted like this:
  # 1299,"HASBRO, INC.",Y
  # 6219,CAMPBELL SOUP COMPANY,Y
  # 12270,NAVY FEDERAL CREDIT UNION,Y
  # For this we will use parser v1 too.

  # To generate the report, use the Rails runner from the container bash
  # $ rails runner -e production "AdobeReport.generate('2018_Adobe_Mobile_SDK_Customers.csv.gz', 'v1')"

  # Upload the produced files to the S3_OUTPUT_BUCKET url (not automated yet)
  # $ aws s3 cp /tmp/adobe.ios.output.csv s3://mightysignal-customer-reports/adobe/output/

  S3_REPORTS_BUCKET = 'mightysignal-customer-reports'
  S3_OBJECT = 'adobe/'
  S3_INPUT_PATH   = S3_OBJECT + 'input/'
  S3_OUTPUT_PATH  = S3_OBJECT + 'output/'

  class << self
    def output_file_ios
      @output_file_ios ||= File.open("/tmp/adobe.ios.output.csv", "w+")
    end

    def output_file_android
       @output_file_android ||= File.open("/tmp/adobe.android.output.csv", "w+")
    end

    def output_publisher_name_to_id
      @output_publisher_name_to_id ||= File.open("/tmp/adobe.output_publisher_name_to_id.csv", "w+")
    end

    def publisher_hot_store
      @publisher_hot_store ||= PublisherHotStore.new
    end

    def apps_hot_store
      @apps_hot_store ||= AppHotStore.new
    end

    def found_sdks
      @found_sdks ||= Set.new
    end

    private :output_file_ios, :output_file_android, :output_publisher_name_to_id, :publisher_hot_store

    # File must be a .gz
    def generate(file_name, version)

      file_content = MightyAws::S3.new.retrieve( bucket: S3_REPORTS_BUCKET,
                                                 key_path: S3_INPUT_PATH + file_name )
      publisher_names = extract_publisher_names(file_content)
      write_header_to_files
      publisher_names.each do |publisher_name|
        process_developer('ios', publisher_name)
        process_developer('android', publisher_name)
      end
      p "Found sdks:"
      p found_sdks.to_a
    ensure
      output_file_ios.close     unless output_file_ios.nil?
      output_file_android.close unless output_file_android.nil?
    end

    private

    def write_header_to_files
      [output_file_ios, output_file_android].each { |file| file.puts(headers_row) }
    end

    def get_publisher_name_words(publisher_name)
      illegal_chars_regex = /[\.,\/'\(\)]/
      dashed_name_regex = /\s+-/
      if publisher_name =~ illegal_chars_regex || publisher_name =~ dashed_name_regex
        publisher_name.gsub(illegal_chars_regex,'').gsub(publisher_name,'').split
      else
        #split string and return all but last element
        words = publisher_name.split[0...-1]
      end
    end

    def process_developer(platform, original_publisher_name, use_regex=false)
      clazz = "#{platform.downcase.titleize}Developer".constantize # Produces: IosDeveloper AndroidDeveloper

      matches = true
      if use_regex
        matches = false
        developers = clazz.where("name REGEXP '[[:<:]]#{get_publisher_name_words(original_publisher_name).join(' ')}[[:>:]]'")
      else
        developers = clazz.where(name: get_publisher_name_words(original_publisher_name).join(' '))
      end

      devs_found_amnt = developers.size
      if devs_found_amnt >= 1
        line = write_row_for(platform, developers.first, original_publisher_name, matches)
        return {}
      else
        words = get_publisher_name_words(original_publisher_name)
        while words.size >= 2 && words.first.downcase != 'the' do
          name = words.join(' ')
          return process_developer(platform, name, true)
        end
        false
      end
    end

    def write_row_for(platform, publisher, original_publisher_name, matches)
      # p "Found #{platform}: " + publisher.name
      found_publisher = publisher_hot_store.read(platform, publisher.id)
      return if found_publisher.empty?
      publisher_apps_map = map_publishers_to_apps(found_publisher)
        produce_csv_line(platform, original_publisher_name, publisher_apps_map, matches)
    end

    def produce_csv_line(platform, original_publisher_name, publisher_apps_map, matches)
      publisher_apps_map.map do |name, apps|
        apps.map do |app|
          if app_uses_adobe_sdk?(app)
            sdks = app['sdk_activity'].map{ |sdkact| if sdkact['name'].downcase =~ /adobe/ && sdkact['installed'] then sdkact['name'] end }.compact
            found_sdks.merge sdks
          end

          line = [original_publisher_name]
          line << name
          line << (matches ? 'Y' : 'N')
          line << app['id']
          line << app['name']
          line << app['original_release_date']
          line << app['all_version_rating'].andand.round(2)
          line << app['all_version_ratings_count'].andand.round(0) #(app['all_version_rating'] && app['all_version_ratings_count'].andand.send(:!=, 0) ? app['all_version_rating'] / app['all_version_ratings_count'] : 0)
          line << app['current_version']
          line << app['current_version_release_date']
          line << (app_uses_adobe_sdk?(app) ? 'Y' : 'N')
          line << app['price']
          line << app['categories'].find { |cat| cat['type'] == 'primary' }.andand['name']
          line << app['publisher'].andand['name']
          line << app['seller']
          if platform == 'ios'
            line << ('https://itunes.apple.com/developer/id' + app['id'].to_s)
          else
            line << ('https://play.google.com/store/apps/details?id=' + app['bundle_identifier'].to_s )
          end
          line << app['headquarters'].map{|hq| hq['state']}.compact.uniq.join('|')
          line << app['headquarters'].map{|hq| hq['country']}.compact.uniq.join('|')
          line << app['sdk_activity'].select{|sdk| sdk['installed']}.size
          line << app['mobile_priority']
          line << app['user_base']
          # line << (app['ratings_by_country'] ? app['ratings_by_country'].sum {|rt| rt['ratings_per_day_current_release']} : 0)
          print_line = line.join(';')
          p print_line
          send("output_file_#{platform}".to_sym).puts(print_line)
        end
      end
    rescue => e
      p "Error writing to file"
      p e
    end

    def app_uses_adobe_sdk?(app)
      app['sdk_activity'].find{ |sdkact| sdkact['name'].downcase =~ /adobe/ && sdkact['installed'] }.present?
    end

    def map_publishers_to_apps(found_publisher)
      publisher_apps = found_publisher['apps']
      publisher_apps.reduce({}) do |result, app_hash|
        found_app = apps_hot_store.read(app_hash['platform'], app_hash['id'])
        next result if found_app.empty? || found_app['taken_down']
        if result[found_publisher['name']].blank?
          result[found_publisher['name']] = [found_app]
        else
          result[found_publisher['name']] << found_app
        end
        result
      end
    end

    def extract_publisher_names(str)
      # Lines come as    "1493687,SB MULTIMEDIA PVT. LTD,Y\r\n"
      # some have quotes "1473563,\"TOYOTA MOTOR NORTH AMERICA, INC.\",Y\r\n",
      str.lines.map { |ln| if ln =~ /(\d+),(.*),(.?)/ then $2.gsub('"','') end }.compact
    end

    def headers_row
      [
        'Publisher name',
        'Guessed Publisher',
        'Matches?',
        'App Id',
        'App Name',
        'First realease date',
        'All versions rating',
        'All versions ratings count',
        'Current version',
        'Current version release date',
        'Uses Adobe SDK?',
        'Price',
        'Categories',
        'Publisher',
        'Seller',
        'URL',
        'States',
        'Countries',
        'Installed SDKs',
        'Mobile priority',
        'User base'
      ].join(';')
    end
  end
end
