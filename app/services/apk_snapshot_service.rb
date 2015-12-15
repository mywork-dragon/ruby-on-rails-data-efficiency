class ApkSnapshotService
  
  class << self

    def run(notes, size = 10)
      batch = Sidekiq::Batch.new
      batch.description = "scrape #{size} apks from google play"
      # batch.on(:complete, ApkSnapshotService)
      batch.jobs do
        j = ApkSnapshotJob.create!(notes: notes)
          AndroidApp.where(display_type: 0, newest_apk_snapshot_id: nil).joins(:newest_android_app_snapshot).where('android_app_snapshots.price = ? AND android_app_snapshots.released > ?',0,1.year.ago).limit(size).each.with_index do |app, index|
            li "app #{index}"
            ApkSnapshotServiceWorker.perform_async(j.id, batch.bid, app.id)
          end
      end
      # daemon :start
      puts Sidekiq::Queue.new('sdk').size
    end
    
    def daemon(command)
      ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address()
      if ip == '172.31.38.183'
        `ruby 'app/services/sidekiq_service_controller.rb' #{command}`
      else
        puts "You can only run the Sidekiq monitoring daemon on sdk_scraper1."
      end
    end

  end

  # def on_complete(status, options)
  #   self.class.daemon :stop
  # end
  
end