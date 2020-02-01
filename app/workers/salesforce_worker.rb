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

  def sync_all_accounts
    Account.where.not(salesforce_refresh_token: nil).where(salesforce_syncing: true).ready.pluck(:id).each do |account_id|
      SalesforceWorker.perform_async(:sync_account, account_id)
    end
  end

  def sync_account(account_id)
    account = Account.find(account_id)
    sf = SalesforceExportService.new(user: account.users.first)
    sf.sync_all_objects
  end

  def sync_domain_mapping_all_accounts(frequency: '1w', queue: :salesforce_syncer)
    return unless frequency
    Account.where.not(salesforce_refresh_token: nil).where(salesforce_syncing: true).ready.each do |account|
      if account.domain_syncing_frequency == frequency
        SalesforceWorker.set(queue: queue).perform_async(:sync_domain_mapping, account.id, frequency_to_relative_time(frequency), queue)
      end
    end
  end

  def sync_domain_mapping(account_id, date = nil, queue = :salesforce_syncer)
    account = Account.find(account_id)
    puts "Will use user: #{account.users.first.id}"
    sf = SalesforceExportService.new(user: account.users.first)
    puts ''
    puts "sf.under_api_limit?: #{sf.under_api_limit?}"
    if sf.under_api_limit?(uses_bulk_api: true)
      sf.sync_domain_mapping(date: date, queue: queue)
    else
      SalesforceWorker.perform_in(6.hours, :sync_domain_mapping, account_id, date, queue)
    end
  end

  # for bulk exporting
  def export_ios_publisher(publisher_id, export_id, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)
    puts ''
    puts "sf.under_api_limit?: #{sf.under_api_limit?}"

    if sf.under_api_limit?
      dev = IosDeveloper.find(publisher_id)
      sf.export(publisher: dev, object_id: export_id, export_apps: false)
    else
      SalesforceWorker.perform_in(6.hours, :export_ios_publisher, publisher_id, export_id, user_id, model_name)
    end
  end

  def export_android_publisher(publisher_id, export_id, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)

    if sf.under_api_limit?
      dev = AndroidDeveloper.find(publisher_id)
      sf.export(publisher: dev, object_id: export_id, export_apps: false)
    else
      SalesforceWorker.perform_in(6.hours, :export_android_publisher, publisher_id, export_id, user_id, model_name)
    end
  end

  # imports is an array of android/ios publishers and salesforce objects to import into
  def export_publishers_apps(imports, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)

    if sf.under_api_limit?(uses_bulk_api: true)
      imports.each do |import|
        import['publisher'] = if import['platform'] == 'ios'
          IosDeveloper.find(import['publisher_id'])
        else
          AndroidDeveloper.find(import['publisher_id'])
        end
      end

      sf.import_publishers_apps(imports)
    else
      SalesforceWorker.perform_in(6.hours, :export_publishers_apps, imports, user_id, model_name)
    end
  end

  def export_ios_apps(app_id, export_id, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)
    if sf.under_api_limit?(uses_bulk_api: true)
      app = IosApp.find(app_id)
      sf.import_publishers_apps([{publisher: app.ios_developer, export_id: export_id}])
    else
      SalesforceWorker.perform_in(6.hours, :export_ios_apps, app_id, export_id, user_id, model_name)
    end
  end

  def export_android_apps(app_id, export_id, user_id, model_name)
    sf = SalesforceExportService.new(user: User.find(user_id), model_name: model_name)

    if sf.under_api_limit?(uses_bulk_api: true)
      app = AndroidApp.find(app_id)
      sf.import_publishers_apps([{publisher: app.android_developer, export_id: export_id}])
    else
      SalesforceWorker.perform_in(6.hours, :export_android_apps, app_id, export_id, user_id, model_name)
    end
  end

  private

  def frequency_to_relative_time(frequency)
    mapping = {
      '5m' => 'YESTERDAY'
    }

    mapping[frequency]
  end

end
