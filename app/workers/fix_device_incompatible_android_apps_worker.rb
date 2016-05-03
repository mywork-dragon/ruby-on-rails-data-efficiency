#one time thing
class FixDeviceIncompatibleAndroidAppsWorker

  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(android_app_id)
    aa = AndroidApp.find(android_app_id)
    aa.display_type = 0
    aa.save!
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'FixDeviceIncompatibleAndroidAppsWorker finished')
  end

  class << self

    def run
      aas = AndroidApp.where(display_type: [3, nil])

      batch = Sidekiq::Batch.new
      batch.description = "FixDeviceIncompatibleAndroidAppsWorker"
      batch.on(:complete, "FixDeviceIncompatibleAndroidAppsWorker#on_complete")

      batch.jobs do 
        aas.each do |aa|
          FixDeviceIncompatibleAndroidAppsWorker.perform_async(aa.id)
        end
      end 
    end

  end

end