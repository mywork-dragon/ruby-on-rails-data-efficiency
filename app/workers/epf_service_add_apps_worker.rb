class EpfServiceAddAppsWorker
  include Sidekiq::Worker

  def perform(ios_app_epf_snapshot_ids)
    ios_app_epf_snapshot_ids.each do |id|
    
      ios_app_epf_snapshot = IosAppEpfSnapshot.find(id)
      
      app_identifier = ios_app_epf_snapshot.application_id
      
      ios_app = IosApp.find_by_app_identifier(app_identifier)
      
      if ios_app.blank?
        IosApp.create(app_identifier: app_identifier)
      end
    
    end
  end
  
end