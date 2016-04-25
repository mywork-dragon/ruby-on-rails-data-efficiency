class IosPackageReclassificationService

  class << self

    # Reclassify packages specified by array of sdk_package_ids
    # Ex. IosPackageReclassificationService.reclassify_packages([1, 2], 2)
    def reclassify_packages(sdk_package_ids, new_sdk_id = nil)

      packages = SdkPackage.where(id: sdk_package_ids)

      previous_sdk_id = packages.pluck(:ios_sdk_id).uniq

      raise "Packages should all have the same previous sdk id" if previous_sdk_id.length != 1
      
      previous_sdk_id = previous_sdk_id.first

      packages.update_all(ios_sdk_id: new_sdk_id)

      batch = Sidekiq::Batch.new
      batch.description = "Reclassifying packages #{sdk_package_ids.join(',')}"
      batch.on(:complete, 'IosPackageReclassificationService#on_complete')

      IpaSnapshot.distinct.joins(:sdk_packages).where('sdk_packages.id in (?)', sdk_package_ids).find_in_batches(batch_size: 1000).with_index do |query_batch, index|

        puts "Batch #{index}" if index % 10 == 0

        if Rails.env.production?

          batch.jobs do

            query_batch.each do |ipa_snapshot|
              IosPackageReclassificationWorker.perform_async(ipa_snapshot.id, previous_sdk_id, new_sdk_id)
            end

          end

        else
            query_batch.each do |ipa_snapshot|
              IosPackageReclassificationWorker.new.perform(ipa_snapshot.id, previous_sdk_id, new_sdk_id)
            end
        end

      end

    end

  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'updated package classification')
  end

end
