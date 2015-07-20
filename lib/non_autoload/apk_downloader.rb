# Patch for 1.1.5
if defined?(ApkDownloader)
  ApkDownloader.module_eval do
  	def download! package, destination, apk_snap_id
      @api ||= Api.new
      data = @api.fetch_apk_data package, apk_snap_id
      File.open(destination, 'wb') { |f| f.write data }
    end
  end
end