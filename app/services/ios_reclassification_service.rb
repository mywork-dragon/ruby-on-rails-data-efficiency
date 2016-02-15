class IosReclassificationService
  class << self
    def reclassify_current_newest
      apps = IosApp.joins(:ipa_snapshots).select(:id).distinct.where('ipa_snapshots.success = true').where("ipa_snapshots.scan_status = #{IpaSnapshot.scan_statuses[:scanned]}")

      batch = Sidekiq::Batch.new
      batch.description = "reclassifying snapshots" 
      batch.on(:complete, 'IosReclassificationService#on_complete')

      apps.find_in_batches(batch_size: 1000).with_index do |query_batch, index|
        puts "Batch #{index}" if index % 10 == 0
        batch.jobs do
          query_batch.each do |ios_app|
            ipa_snapshot = ios_app.get_last_ipa_snapshot(scan_success: true)
            IosReclassificationServiceWorker.perform_async(ipa_snapshot.id) unless ipa_snapshot.blank?
          end
        end
      end

    end
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Finished iOS reclassification')
  end
end