class EpfServiceAddAppsWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :low

  def perform(ios_app_epf_snapshot_ids)
    ios_app_epf_snapshot_ids.each do |id|
    
      ios_app_epf_snapshot = IosAppEpfSnapshot.find(id)
      
      app_identifier = ios_app_epf_snapshot.application_id
      
      ios_app = IosApp.find_by_app_identifier(app_identifier)
      
      if ios_app.blank?
        ios_app = IosApp.create(app_identifier: app_identifier)
      end
    
      if ios_app.released.blank?
        ios_app.released = ios_app_epf_snapshot.itunes_release_date

        ios_app.save
      end



    end
  end
  
end