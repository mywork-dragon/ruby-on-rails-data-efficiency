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

  def sync_all_objects
    Account.where.not(salesforce_refresh_token: nil).where(salesforce_status: :ready).each do |account|
      sf = SalesforceExportService.new(user: account.users.first)
      sf.sync_all_objects
    end
  end

  def export_ios_apps(app_id, export_id, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)
    app = IosApp.find(app_id)
    sf.import_publisher(app.ios_developer, export_id)
  end

  def export_android_apps(app_id, export_id, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)
    app = AndroidApp.find(app_id)
    sf.import_publisher(app.android_developer, export_id)
  end

end