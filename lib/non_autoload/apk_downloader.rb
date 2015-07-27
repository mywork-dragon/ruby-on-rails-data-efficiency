# Patch for 1.1.5
module ApkDownloader
  class << self
    def download! package, destination, apk_snap_id
      @api ||= Api.new
      data = @api.fetch_apk_data package, apk_snap_id
      
      if data.blank?
      	as = ApkSnapshot.find_by_id(apk_snap_id)
        as.status = :failure
        as.save
        raise "empty app"
       end

      File.open(destination, 'wb') { |f| f.write data }
    end
  end
end