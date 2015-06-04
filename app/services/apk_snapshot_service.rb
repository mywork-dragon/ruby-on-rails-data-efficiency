class ApkSnapshotService
  
  class << self
  
    def run(notes)
      
      j = ApkSnapshotJob.create!(notes: notes)
      
      AndroidApp.select(:id).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).limit(2000).find_each do |app|
        # ApkSnapshotServiceWorker.perform_async(j.id, app.id)
        ApkSnapshotServiceWorker.new.perform(j.id, app.id)
      end
      
    end
  
  end
  
end