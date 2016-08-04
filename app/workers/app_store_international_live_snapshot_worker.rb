class AppStoreInternationalLiveSnapshotWorker
  include Sidekiq::Worker
  include AppStoreInternationalSnapshotModule
  
  sidekiq_options retry: 1, queue: :sdk_live_scan

  def initialize
    @current_tables = true
  end

  class << self

    def test
      # uber, snapchat, dash (mac app)
      app_identifiers = [368677368, 447188370, 449589707]
      ios_apps = app_identifiers.map do |app_identifier|
        IosApp.find_or_create_by!(app_identifier: app_identifier)
      end

      app_store = AppStore.find_or_create_by!(country_code: 'us')
      job = IosAppCurrentSnapshotJob.find_or_create_by!(id: 1)

      new.perform(job.id, ios_apps.map(&:id), app_store.id)
    end
  end
end
