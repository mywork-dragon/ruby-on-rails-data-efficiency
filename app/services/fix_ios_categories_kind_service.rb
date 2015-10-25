class FixIosCategoriesKindService

  class << self

    def fix_primary
      IosAppCategoriesSnapshot.where(kind: 'primary').find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "##{index}"
        ids = batch.map{ |iac| iac.id}
        FixIosCategoriesWorker.perform_async(ids, 0)
      end
    end

    def fix_secondary
      IosAppCategoriesSnapshot.where(kind: 'primary').find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "##{index}"
        ids = batch.map{ |iac| iac.id}
        FixIosCategoriesWorker.perform_async(ids, 1)
      end
    end

  end



end