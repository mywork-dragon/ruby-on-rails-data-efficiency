# Patch for 1.1.5
module ApkDownloader

  FETCH_DATA_ATTEMPTS = 3
  FETCH_DATA_RETRY_SLEEP = 5 # seconds

  class << self

    def download! package, destination, android_id, email, password, proxy_ip, proxy_port
      @api ||= Api.new(android_id, email, password, proxy_ip, proxy_port)
      
      data = nil

      FETCH_DATA_ATTEMPTS.times do |attempt|
        puts "@api.fetch_apk_data package, attempt #{attempt}"
        data = @api.fetch_apk_data package
        break unless data.blank?
        sleep FETCH_DATA_RETRY_SLEEP
      end

      fail EmptyApp if data.blank?

      puts "Got download contents: #{Time.now}"

      File.open(destination, 'wb') { |f| f.write data }
    end
    
  end

  ### Custom Errors

  class ResponseError < StandardError
    attr_reader :status
    attr_reader :display_type
    attr_reader :status_code

    def initialize(message = nil, status: nil, display_type: nil, status_code: nil)
      @status = status
      @display_type = display_type
      @status_code = status_code
      super(message)
    end
    
  end

  class EmptyApp < StandardError
    def initialize(message = "empty app")
      super
    end
  end

  class EmptyRecursiveApkFetch < ResponseError
    def initialize(message = "recursive_apk_fetch returned empty")
      super
    end
  end

  class UnableToLogIn < StandardError
    def initialize(message = "Unable to log in")
      super
    end
  end

  class NoAuthToken < StandardError
    def initialize(message = "Could not parse out auth token")
      super
    end
  end

  class NoApkDataUrl < StandardError
    def initialize(message = "No APK data URL")
      super
    end
  end

  class NoApkDataCookie < StandardError
    def initialize(message = "No APK data cookie")
      super
    end
  end

  class Response403 < ResponseError
    def initialize(message = "403 Response", status: nil, display_type: nil, status_code: nil)
      super
    end
  end

  class Response404 < ResponseError
    def initialize(message = "404 Response", status: nil, display_type: nil, status_code: nil)
      super
    end
  end

  class Response500 < ResponseError
    def initialize(message = "500 Response", status: nil, display_type: nil, status_code: nil)
      super
    end
  end

  class ResponseOther < ResponseError
    def initialize(message = "Other Response", status: nil, display_type: nil, status_code: nil)
      super
    end
  end



end