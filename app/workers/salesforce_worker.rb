class SalesforceWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :salesforce_syncer

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

  # for bulk exporting
  def export_ios_publisher(publisher_id, export_id, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)
    dev = IosDeveloper.find(publisher_id)
    sf.export(publisher: dev, object_id: export_id, export_apps: false)
  end

  def export_android_publisher(publisher_id, export_id, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)
    dev = AndroidDeveloper.find(publisher_id)
    sf.export(publisher: dev, object_id: export_id, export_apps: false)
  end

  # imports is an array of android/ios publishers and salesforce objects to import into
  def export_publishers(imports, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)
    imports.each do |import|
      import['publisher'] = if import['platform'] == 'ios'
        IosDeveloper.find(import['publisher_id'])
      else
        AndroidDeveloper.find(import['publisher_id'])
      end
    end
    sf.import_publishers(imports)
  end

  def export_ios_apps(app_id, export_id, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)
    app = IosApp.find(app_id)
    sf.import_publishers([{publisher: app.ios_developer, export_id: export_id}])
  end

  def export_android_apps(app_id, export_id, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)
    app = AndroidApp.find(app_id)
    sf.import_publishers([{publisher: app.android_developer, export_id: export_id}])
  end

end