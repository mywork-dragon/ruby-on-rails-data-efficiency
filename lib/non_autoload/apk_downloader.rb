ApkDownloader.module_eval do

  class << self

    def testo
      puts "HOLLAAAA"
    end

    def download! package, destination
      do_something_else
            
      @api ||= Api.new
      data = @api.fetch_apk_data package
      File.open(destination, 'wb') { |f| f.write data }
    end
  end
  
end