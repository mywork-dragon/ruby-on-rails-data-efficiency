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
        IosApp.where(id: ids).find_each do |ios_app|
          IosMassScanServiceWorker.perform_async(ipa_snapshot_job.id, ios_app.id)
        end
      else
        ios_app_id = IosApp.where(id: ids).pluck(:id).sample
        IosMassScanServiceWorker.new.perform(ipa_snapshot_job.id, ios_app_id)
      end
    end
  end

end
