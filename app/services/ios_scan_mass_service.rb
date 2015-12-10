class IosScanMassService

  class << self

    def run_n(notes, n: 10)
    
    ipa_snapshot_job = IpaSnapshotJob.create!(job_type: :mass, notes: notes)

      IosApp.first(n).each do |ios_app|
        IosMassScanServiceWorker.perform_async(ipa_snapshot_job.id, ios_app.id)
      end
      
    end

    def run_ids(notes, ids)

      ipa_snapshot_job = IpaSnapshotJob.create!(job_type: :mass, notes: notes)

      if Rails.env.production?
        IosApp.where(id: ids).each do |ios_app|
          IosMassScanServiceWorker.perform_async(ipa_snapshot_job.id, ios_app.id)
        end
      else
        ios_app = IosApp.where(id: ids).sample
        IosMassScanServiceWorker.new.perform(ipa_snapshot_job.id, ios_app.id)
      end
    end
  end

end
