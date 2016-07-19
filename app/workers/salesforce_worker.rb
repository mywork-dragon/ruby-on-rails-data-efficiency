class SalesforceWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :mailers

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def add_lead(data)
    LeadSalesforceService.add_to_salesforce(data)
  end

end