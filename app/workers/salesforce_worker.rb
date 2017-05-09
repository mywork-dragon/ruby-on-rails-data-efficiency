class SalesforceWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :mailers

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def add_lead(data)
    SalesforceLeadService.add_to_salesforce(data)
  end

  def setup_export(user_id)
    user = User.find(user_id)
    SalesforceExportService.new(user: user).install
  end

end