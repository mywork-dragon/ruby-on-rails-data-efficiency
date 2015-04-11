class DownloadsSnapshotService
  
  class << self
    
    def run(notes, options={})

      j = IosAppDownloadSnapshotJob.create!(notes: notes)

      IosApp.find_each.with_index do |ios_app, index|
        li "App ##{index}" if index%10000 == 0
        DownloadsSnapshotServiceWorker.perform_async(j.id, ios_app.id)
      end

    end
    
  end
  
end