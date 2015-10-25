class FixIosCategoriesKindService

  class << self

    def fix_primary
      batch = Sidekiq::Batch.new
      batch.description = "fix_primary" 
      batch.on(:complete, 'FixIosCategoriesKindService#on_complete_fix_primary')

      batch.jobs do
        IosAppCategoriesSnapshot.where(kind: 'primary').find_each.with_index do |iacs, index|
          li "IosAppCategoriesSnapshot ##{index}" if index % 1000 == 0
          FixIosCategoriesWorker.perform_async(iacs.id, 0)
        end
      end
    end

    def fix_secondary
      batch = Sidekiq::Batch.new
      batch.description = "fix_secondary" 
      batch.on(:complete, 'FixIosCategoriesKindService#on_complete_fix_secondary')

      batch.jobs do
        IosAppCategoriesSnapshot.where(kind: 'secondary').find_each.with_index do |iacs, index|
          li "IosAppCategoriesSnapshot ##{index}" if index % 1000 == 0
          FixIosCategoriesWorker.perform_async(iacs.id, 1)
        end
      end
    end


    def on_complete_fix_primary(status, options)
      Slackiq.notify(webhook_name: :main, status: status, title: 'fix_primary')
    end

  end



end