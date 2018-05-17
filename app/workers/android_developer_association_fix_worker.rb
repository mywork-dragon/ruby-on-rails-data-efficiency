
class AndroidDeveloperAssociationFixWorker
  include Sidekiq::Worker

  sidekiq_options queue: :google_play_snapshot_mass_worker, retry: false


  def perform(android_app_id)

  end

  def update_android_developer
    # Some of this logic is redundant with that in GooglePlayDevelopersWorker
    # In fact the GooglePlayDevelopersWorker flow can be phased out once website attribution is not longer required.
    if ! @snapshot.developer_google_play_identifier.nil?
      developer = AndroidDeveloper.find_by_identifier(@snapshot.developer_google_play_identifier)
      if developer.nil?
        begin
          developer = AndroidDeveloper.create!(
            identifier: @snapshot.developer_google_play_identifier,
            name: @snapshot.seller
          )
        rescue ActiveRecord::RecordNotUnique
          developer = AndroidDeveloper.find_by_identifier!(@snapshot.developer_google_play_identifier)
        end
      end
      if developer != @android_app.android_developer
        @android_app.android_developer = developer
        @android_app.save!
      end
    end
  end

end
