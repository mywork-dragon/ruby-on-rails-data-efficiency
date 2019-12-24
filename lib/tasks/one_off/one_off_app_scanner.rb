class OneOffAppScanner
  S3_BUCKET = 'mightysignal-one-ff-tasks'.freeze
  S3_FOLDER = 'apps_lists'.freeze
  
  class << self
    
    attr_reader :filename
    
    def process_file(filename)
      @filename = filename
      
      file_content = MightyAws::S3.new.retrieve( bucket: S3_BUCKET, key_path: S3_FOLDER + '/' + filename, ungzip: false )
      apps_data = CSV.parse(file_content, :headers => true)
      headers, *apps_data = apps_data.to_a
      fields_map = headers.each_with_index.inject({}){|memo,(name, position)| memo[name] = position and memo }
      
      android_ids = []
      ios_ids = []
      
      apps_data.each do |app_line| 
        if app_line[fields_map['platform']] =~ /android/i
          app_identifier =  app_line[fields_map['bundle id']]
          if app_identifier
            android_app = (AndroidApp.find_by(app_identifier: app_identifier) rescue nil)
            android_ids << android_app.id if android_app
          end
        end
        
        if app_line[fields_map['platform']] =~ /ios/i
          app_identifier = app_line[fields_map['bundle id']]
          if app_identifier
            ios_app = (IosApp.find_by(app_identifier: app_identifier) rescue nil)
            ios_ids << ios_app.id
          end
        end
      end
      AndroidMassScanService.run_by_ids(android_ids, use_batch: true)
      
      # IosMassScanService.run_ids('Scan by request', ios_ids, use_batch: true)
      
      ios_ids.each do |ios_id|
        begin
          IosLiveScanService.scan_ios_app(ios_app_id: ios_id, job_type: :one_off, international_enabled: true)
        rescue => e 
          print e.message
        end
      end
    end
    
    private
    
    def valid_file_size?
      MightyAws::S3.new.content_length(bucket: S3_BUCKET, key_path: S3_FOLDER + '/' + filename) <= MAX_FILE_SIZE
    end
  end
end