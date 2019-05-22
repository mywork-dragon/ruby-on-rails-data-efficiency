# Couldn't find where this code is used

# class AppPermissionsHotstoreImportWorker
#   include Sidekiq::Worker
#   sidekiq_options queue: :hot_store_application_import, retry: 2
#
#   def initialize
#     @importer = AppPermissionsHotstoreImporter.new
#   end
#
#   def perform(app_ids)
#     app_ids.each do |id|
#       @importer.import_ios(id)
#     end
#   end
#
#   def queue_ios_apps
#     IosApp
#       .where.not(:display_type => IosApp.display_types[:not_ios])
#       .where.not(newest_ipa_snapshot_id: nil)
#       .pluck(:id).each_slice(100) do |ids|
#       AppPermissionsHotstoreImportWorker.perform_async(ids)
#     end
#   end
#
# end
