class IosNewestIpaSnapshot
  class << self
    def update_all_pointers

      batch = Sidekiq::Batch.new
      batch.description = "Updating ios app newest ipa snapshot pointers"
      batch.on(:complete, 'IosNewestIpaSnapshot#on_complete')

      IosApp.distinct.joins(:ipa_snapshots).find_in_batches(batch_size: 1000).with_index do |app_batch, index|
        puts "Batch #{index}" if index % 10 == 0
        batch.jobs do
          app_batch.each do |ios_app|
            IosAppNewestPointerWorker.perform_async(ios_app.id)
          end
        end        
      end

      puts "Done queueing"

    end
  end
end