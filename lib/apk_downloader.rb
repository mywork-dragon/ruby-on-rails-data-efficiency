require 'apk_downloader/googleplay.pb'

module ApkDownloader
  load :Configuration,  'apk_downloader/configuration'
  load :Api,            'apk_downloader/api'

  class << self
    attr_reader :configuration, :api

    def configure
      @configuration ||= Configuration.new
      yield configuration
    end

    def download! package, destination
      @api ||= Api.new
      data = @api.fetch_apk_data package
      File.open(destination, 'wb') { |f| f.write data }
    end
  end
end
