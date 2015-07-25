# Patch for 1.1.5
module ApkDownloader
  class << self
    def download! package, destination, apk_snap_id
      @api ||= Api.new
      data = @api.fetch_apk_data package, apk_snap_id
      raise "empty app" if data.blank?
      File.open(destination, 'wb') { |f| f.write data }
    end
  end
end