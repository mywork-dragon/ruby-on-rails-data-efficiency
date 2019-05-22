#  Couldn't find where this class is being used

# class AndroidSdkDataCleansingService
#
#   class << self
#
#     def set_first_valid_date_and_good_as_of_date
#       batch = Sidekiq::Batch.new
#       batch.description = "AndroidSdkDataCleansingService set_first_valid_date_and_good_as_of_date"
#       batch.on(:complete, "AndroidSdkDataCleansingService#on_complete")
#       batch_size = 10e3.to_i
#       ApkSnapshot.where("first_valid_date IS NULL OR good_as_of_date IS NULL").find_in_batches(batch_size: batch_size).with_index do |the_batch, index|
#         batch.jobs do
#           li "ApkSnapshot #{index*batch_size}"
#           args = the_batch.map{ |apk_ss| [apk_ss.id] }
#           Sidekiq::Client.push_bulk('class' => SetFirstValidDateAndGoodAsOfDateForApkSnapshotsWorker, 'args' => args)
#         end
#       end
#     end
#
#   end
#
#   def on_complete(status, options)
#     Slackiq.notify(webhook_name: :main, status: status, title: 'AndroidSdkDataCleansingService set_first_valid_date_and_good_as_of_date complete')
#   end
#
# end
