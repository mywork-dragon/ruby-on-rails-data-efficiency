class IosReclassificationService
  class << self
    def reclassify_all
      batch = Sidekiq::Batch.new
      batch.description = "reclassifying snapshots" 
      batch.on(:complete, 'IosReclassificationService#on_complete')

      batch.jobs do
        IosReclassificationQueueWorker.perform_async
      end
    end

    def reclassify_ios_apps(ios_app_ids)
      batch = Sidekiq::Batch.new
      batch.description = "reclassifying snapshots" 
      batch.on(:complete, 'IosReclassificationService#on_complete')

      batch.jobs do
        IpaSnapshot.select(:id).where(
          ios_app_id: ios_app_ids,
          success: true,
          scan_status: IpaSnapshot.scan_statuses[:scanned]
        ).each do |ipa_snapshot|
          IosReclassificationServiceWorker.perform_async(ipa_snapshot.id)
        end
      end
    end

    def reclassify_classdump_ids(classdump_ids)
      snapshot_ids = IpaSnapshot
        .joins(:class_dumps)
        .where('class_dumps.id in (?)', classdump_ids)
        .where(success: true, scan_status: IpaSnapshot.scan_statuses[:scanned])
        .pluck(:id)

      snapshot_ids = snapshot_ids.map { |x| [x] }

      snapshot_ids.each_slice(500) do |id_arrs|
        Sidekiq::Client.push_bulk(
          'queue' => 'ios_reclassification',
          'class' => IosReclassificationServiceWorker,
          'args' => id_arrs
        )
      end
    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Finished iOS reclassification')
  end
end
