class ApkSnapshotService
  
  class << self
  
    def run(notes)
      
      j = ApkSnapshotJobs.create!(notes: notes, is_fucked: 0)
      
      AndroidApp.select(:id).joins(:newest_android_app_snapshot).where("android_app_snapshots.price = ?", 0).find_each do |app|
        # ApkSnapshotServiceWorker.perform_async(j.id, app.id)
        ApkSnapshotServiceWorker.new.perform(j.id, app.id)
      end
      
    end
  
  end
  
end