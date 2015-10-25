class FixIosCategoriesKindService

  class << self

    def fix_primary
      batch = Sidekiq::Batch.new
      batch.description = "fix_primary" 
      batch.on(:complete, 'FixIosCategoriesKindService#on_complete_fix_primary')

      batch.jobs do
        IosAppCategoriesSnapshot.where(kind: 'primary').find_in_batches(batch_size: 1000).with_index do |batch, index|
          li "##{index}"
          ids = batch.map{ |iac| iac.id}
          FixIosCategoriesWorker.perform_async(ids, 0)
        end
      end
    end

    def fix_secondary
      batch = Sidekiq::Batch.new
      batch.description = "fix_secondary" 
      batch.on(:complete, 'FixIosCategoriesKindService#on_complete_fix_secondary')

      batch.jobs do
        IosAppCategoriesSnapshot.where(kind: 'primary').find_in_batches(batch_size: 1000).with_index do |batch, index|
          li "##{index}"
          ids = batch.map{ |iac| iac.id}
          FixIosCategoriesWorker.perform_async(ids, 1)
        end
      end
    end


    def on_complete_fix_primary(status, options)
      Slackiq.notify(webhook_name: :main, status: status, title: 'fix_primary')
    end

    def on_complete_fix_secondary(status, options)
      Slackiq.notify(webhook_name: :main, status: status, title: 'fix_secondary')
    end

  end



end