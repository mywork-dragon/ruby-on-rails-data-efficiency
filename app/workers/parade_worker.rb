class ParadeWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :salesforce_syncer

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def queue_ios_advertisers
    titles = ['marketing', 'acquisition', 'creative', 'growth', 'advertising', 'ads', 'performance']
    IosFbAd.joins(:ios_app => :ios_developer).pluck('ios_developers.id').each do |dev_id|
      titles.each do |title|
        ParadeWorker.perform_async(:log_ios_advertiser, dev_id, title)
      end
    end
  end

  def log_ios_adveritiser(dev_id, title)
    contact_service = ContactDiscoveryService.new
    dev = IosDeveloper.find(dev_id)
    contacts = contact_service.get_contacts_for_developer(dev, title)

    contacts.each do |contact|
      if contact[:email]
        ParadeLeadsLogger.new(contact[:givenName], contact[:familyName], contact[:email], contact[:title]).send!
      end
    end
  end

end