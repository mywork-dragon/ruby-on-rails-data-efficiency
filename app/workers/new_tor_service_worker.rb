class NewTorServiceWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: false

  def perform(ios_app_id)
    
    ios_app = IosApp.find(ios_app_id)
    
    a = AppStoreService.attributes(ios_app.app_identifier)
    
    st = SidekiqTester.new
    
    st.test_string = a[:name]
    st.ip =  MyIp.ip
    
    st.save

  end
end