# Couldn't find where this is used

#
# class AndroidDeveloperAssociationFixWorker
#   include Sidekiq::Worker
#
#   sidekiq_options queue: :google_play_snapshot_mass_worker, retry: false
#
#
#   def perform(android_app_id)
#     @android_app = AndroidApp.find(android_app_id)
#     @snapshot = @android_app.newest_android_app_snapshot
#     if ! @snapshot.developer_google_play_identifier.nil?
#       developer = AndroidDeveloper.find_by_identifier(@snapshot.developer_google_play_identifier)
#       if developer.nil?
#         begin
#           developer = AndroidDeveloper.create!(
#             identifier: @snapshot.developer_google_play_identifier,
#             name: @snapshot.seller
#           )
#         rescue ActiveRecord::RecordNotUnique
#           developer = AndroidDeveloper.find_by_identifier!(@snapshot.developer_google_play_identifier)
#         end
#       end
#       if developer != @android_app.android_developer
#         @android_app.android_developer = developer
#         @android_app.save!
#       end
#     end
#   end
#
# end
