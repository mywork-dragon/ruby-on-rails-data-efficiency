class SalesforceExportService
  attr_reader :client, :metadata_client, :bulk_client, :update_records, :create_records, :upsert_records

  def initialize(user:, model_name: 'Account', logging: false)
    @user = user
    @account = @user.account
    @model_name = model_name
    @logging = logging
    @is_sandbox = @account.salesforce_sandbox?

    @app_model = 'MightySignal_App__c'
    @sdk_model = 'MightySignal_SDK__c'
    @sdk_join_model = 'MightySignal_SDK_App__c'
    @app_ownership_model = 'MightySignal_App_Ownership__c'

    client_id = '3MVG9i1HRpGLXp.pUhSTB.tZbHDa3jGq5LTNGRML_QgvmjyWLmLUJVgg4Mgly3K_uil7kNxjFa0jOD54H3Ex9'

    if @logging
      Restforce.log = true
    end

    host = @is_sandbox ? 'test.salesforce.com' : 'login.salesforce.com'

    @client ||= Restforce.new(
      oauth_token: @account.salesforce_token,
      refresh_token: @account.salesforce_refresh_token,
      authentication_callback: method(:refresh_token),
      instance_url: @account.salesforce_instance_url,
      client_id: client_id,
      client_secret: ENV['SALESFORCE_AUTH_CLIENT_SECRET'],
      api_version: '39.0',
      request_headers: { 'sforce-auto-assign' => 'FALSE' },
      host: host
    )

    @metadata_client ||= Metaforce.new(
                          session_id: @account.salesforce_token, 
                          authentication_handler: method(:update_metadata_token),
                          metadata_server_url: "#{@account.salesforce_instance_url}/services/Soap/m/30.0", 
                          server_url: "#{@account.salesforce_instance_url}/services/Soap/m/30.0",
                          host: host
                        ) 
    if Rails.env.production?
      begin
        @client.query('select Id from Account limit 1') 
      rescue => exception
        Bugsnag.notify(exception)
      end
    end

    @bulk_client = SalesforceBulkApi::Api.new(@client)
    @bulk_client.connection.set_status_throttle(30)

    reset_bulk_data
  end

  def install
    @metadata_client.create(:custom_object, 
      full_name: @app_model, 
      deploymentStatus: 'Deployed',
      sharingModel: 'ReadWrite',
      label: 'MightySignal App', 
      pluralLabel: 'MightySignal Apps',
      nameField: {
        label: 'App Name',
        type: 'Text'
      }
    ).on_complete { |job|
      create_app_fields
    }.on_error {|job|
      create_app_fields
    }.perform

    @metadata_client.create(:custom_object, 
      full_name: @sdk_model, 
      deploymentStatus: 'Deployed',
      sharingModel: 'ReadWrite',
      label: 'MightySignal SDK', 
      pluralLabel: 'MightySignal SDKs',
      nameField: {
        label: 'SDK Name',
        type: 'Text'
      }
    ).on_complete { |job|
      create_sdk_fields
    }.on_error {|job|
      create_sdk_fields
    }.perform

    @metadata_client.create(:custom_object, 
      full_name: @sdk_join_model, 
      deploymentStatus: 'Deployed',
      sharingModel: 'ReadWrite',
      label: 'MightySignal SDKApp', 
      pluralLabel: 'MightySignal SDKApps',
      nameField: {
        label: 'SDKApp Name',
        type: 'Text'
      }
    ).on_complete { |job|
      create_sdkapp_fields
    }.on_error {|job|
      create_sdkapp_fields
    }.perform

    @metadata_client.create(:custom_object, 
      full_name: @app_ownership_model, 
      deploymentStatus: 'Deployed',
      sharingModel: 'ReadWrite',
      label: 'MightySignal AppOwnership', 
      pluralLabel: 'MightySignal AppOwnerships',
      nameField: {
        label: 'MightySignal AppOwnership Name',
        type: 'Text'
      }
    ).on_complete { |job|
      create_app_ownership_fields
    }.on_error {|job|
      create_app_ownership_fields
    }.perform

    create_main_fields

    @account.update_attributes(salesforce_status: :ready)
  end

  def account_app_ownership?
    [1, 12].include? @account.id
  end

  def use_true_update?
    [1, 12, 36].include? @account.id
  end

  def should_sync_publisher?(platform:, publisher_id:, last_synced:)
    return true unless last_synced && use_true_update?
    if platform == 'ios'
      publisher = IosDeveloper.find(publisher_id)
      publisher.apps.limit(500).any?{|app| 
        first_valid_date = app.get_last_ipa_snapshot(scan_success: true).try(:first_valid_date)
        first_valid_date && first_valid_date >= last_synced 
      }
    else
      publisher = AndroidDeveloper.find(publisher_id)
      publisher.apps.limit(500).any?{|app| 
        first_valid_date = app.newest_successful_apk_snapshot ? app.newest_successful_apk_snapshot.first_valid_date : nil
        first_valid_date && first_valid_date >= last_synced 
      }
    end
  end

  def sync_all_objects(batch_size: 50, batch_limit: nil, models: supported_models, platforms: ['ios', 'android'], date: nil)
    sync_models = models & supported_models
    sync_models.each do |model|
      @model_name = model
      model_query = @account.syncing_query(model)
      
      query = "select Id, MightySignal_iOS_Publisher_ID__c, MightySignal_Android_Publisher_ID__c, MightySignal_Last_Synced__c from #{model} where"

      if platforms.include?('ios') && platforms.include?('android')
        query += " (MightySignal_iOS_Publisher_ID__c != null or MightySignal_Android_Publisher_ID__c != null)"
      elsif platforms.include?('ios')
        query += " MightySignal_iOS_Publisher_ID__c != null"
      elsif platforms.include?('android')
        query += " MightySignal_Android_Publisher_ID__c != null"
      end

      query += " and IsConverted = false" if model == 'Lead'
      query += " and CreatedDate > #{date}" if date
      query += " and #{model_query}" if model_query
      query += " LIMIT #{batch_limit * batch_size}" if batch_limit

      imports = []
      sf_cache = []
      @client.query(query).each do |object|
        sf_cache << {
          salesforce_id: object.Id,
          ios_publisher_id: object.MightySignal_iOS_Publisher_ID__c,
          android_publisher_id: object.MightySignal_Android_Publisher_ID__c,
          last_synced: object.MightySignal_Last_Synced__c.try(:to_date)
        }
      end

      sf_cache.each do |sf_record|
        salesforce_id = sf_record[:salesforce_id]
        ios_publisher_id = sf_record[:ios_publisher_id]
        android_publisher_id = sf_record[:android_publisher_id]
        last_synced = sf_record[:last_synced]

        if platforms.include?('ios') && ios_publisher_id && should_sync_publisher?(platform: 'ios', publisher_id: ios_publisher_id, last_synced: last_synced)
          SalesforceWorker.perform_async(:export_ios_publisher, ios_publisher_id, salesforce_id, @user.id, @model_name)
          imports << {publisher_id: ios_publisher_id, platform: 'ios', export_id: salesforce_id}
        end
        if platforms.include?('android') && android_publisher_id && should_sync_publisher?(platform: 'android', publisher_id: android_publisher_id, last_synced: last_synced)
          SalesforceWorker.perform_async(:export_android_publisher, android_publisher_id, salesforce_id, @user.id, @model_name)
          imports << {publisher_id: android_publisher_id, platform: 'android', export_id: salesforce_id}
        end
      end

      imports.each_slice(batch_size).with_index do |slice, i|
        SalesforceWorker.perform_async(:export_publishers_apps, slice, @user.id, @model_name)
        break if batch_limit && ((i + 1) >= batch_limit)
      end
    end
  end

  def create_app_fields
    new_fields = [
      {label: 'MightySignal App ID', type: 'Text', length: 255},
      {label: 'MightySignal Key', type: 'Text', length: 255, externalId: true},
      #{label: 'App Store/Google Play App ID', fullName: "#{@app_model}.App_Store_ID__c", type: 'Text', length: 255},
      {label: 'MightySignal Link', type: 'Url'},
      {label: 'Platform', type: 'Text', length: 255},
      {label: 'SDK Data', type: 'LongTextArea', length: 131072, visibleLines: 10},
      {label: 'Mobile Priority', type: 'Text', length: 255},
      {label: 'User Base', type: 'Text', length: 255},
      {label: 'Category', type: 'Text', length: 255},
      {label: 'Ratings Count', type: 'Number', precision: 18, scale: 0},
      {label: 'Ad Spend', type: 'Checkbox', defaultValue: false},
      {label: 'Release Date', type: 'Date'},
      {label: 'Last Scanned Date', type: 'Date'},
      {label: 'Account Name', type: 'Lookup', fullName: "#{@app_model}.Account__c", referenceTo: 'Account', relationshipName: 'Apps'}
    ]
    new_fields.each do |field|
      add_custom_field(@app_model, field)
    end
  end

  def create_sdk_fields
    new_fields = [
      {label: 'MightySignal SDK ID', type: 'Text', length: 255},
      {label: 'MightySignal Key', type: 'Text', length: 255, externalId: true},
      {label: 'MightySignal Link', type: 'Url'},
      {label: 'Website', type: 'Url'},
      {label: 'Platform', type: 'Text', length: 255},
      {label: 'Category', type: 'Picklist', picklist: {picklistValues: [{fullName: 'Analytics'}]}},
      {label: 'Category ID', type: 'Text', length: 255}
    ]
    new_fields.each do |field|
      add_custom_field(@sdk_model, field)
    end
  end

  def create_sdkapp_fields
    new_fields = [
      {label: 'MightySignal Key', type: 'Text', length: 255, externalId: true},
      {label: 'MightySignal SDK', type: 'MasterDetail', referenceTo: 'MightySignal_SDK__c', relationshipName: 'SDK'},
      {label: 'MightySignal App', type: 'MasterDetail', referenceTo: 'MightySignal_App__c', relationshipName: 'App'},
      {label: 'Installed', type: 'Date'},
      {label: 'Uninstalled', type: 'Date'},
    ]
    new_fields.each do |field|
      add_custom_field(@sdk_join_model, field)
    end
  end

  def create_app_ownership_fields
    new_fields = [
      {label: 'MightySignal Key', type: 'Text', length: 255, externalId: true},
      {label: 'Lead', type: 'Lookup', referenceTo: 'Lead', relationshipName: 'Lead'},
      {label: 'Account', type: 'Lookup', referenceTo: 'Account', relationshipName: 'Account'},
      {label: 'MightySignal App', type: 'MasterDetail', referenceTo: 'MightySignal_App__c', relationshipName: 'Lead_App'},
    ]
    new_fields.each do |field|
      add_custom_field(@app_ownership_model, field)
    end
  end

  def create_main_fields
    supported_models.each do |model|
      fields = data_fields
      fields.each do |field_key, field|
        add_custom_field(model, field)
      end
    end
  end

  def limits
    remaining_limits = @client.limits
    {
      daily_api_calls: remaining_limits["DailyApiRequests"]["Remaining"],
      daily_api_calls_max: remaining_limits["DailyApiRequests"]["Max"],
      daily_bulk_api_calls: remaining_limits["DailyBulkApiRequests"]["Remaining"],
      daily_bulk_api_calls_max: remaining_limits["DailyBulkApiRequests"]["Max"]
    }
  end

  def uninstall
    @metadata_client.delete(:custom_object, 
      @app_model, 
    ).on_complete { |job| puts "Custom object deleted." }.perform
  end

  def search(query)
    search_queries = {
      Account: "select Id, Name from Account where Name LIKE '%#{query}%'",
      Lead: "select Id, Company, Title from Lead where Company LIKE '%#{query}%'",
    }.with_indifferent_access

    results = @client.query(search_queries[@model_name])
    results = results.map{|result|
      object = {}
      case @model_name
      when 'Account'
        object[:name] = result.Name
      when 'Lead'
        title = result.Title
        object[:name] = "#{title}\n#{result.Company}"
        object[:title] = title
      end

      object[:id] = result.Id
      object
    }
    results
  end

  def default_mapping(app: nil, publisher: nil)
    mapping = {}
    mapping[WEBSITE] = {"id"=>"Website", "name"=>"Website"}
    mapping[LAST_SYNCED] = {"id"=>"MightySignal_Last_Synced__c", "name"=>"New Field: MightySignal Last Synced"}

    platform = app.try(:platform) || publisher.try(:platform)

    case platform.to_s
    when 'ios'
      mapping[IOS_PUB_ID] = {"id"=>"MightySignal_iOS_Publisher_ID__c", "name"=>"New Field: MightySignal iOS Publisher ID"}
      #mapping[APP_STORE_PUB_ID] = {"id"=>"App_Store_Publisher_ID__c", "name"=>"New Field: App Store Publisher ID"}
      mapping[IOS_LINK] = {"id"=>"MightySignal_iOS_Link__c", "name"=>"New Field: MightySignal iOS Link"}
      mapping[IOS_SDK_SUMMARY] = {"id"=>"MightySignal_iOS_SDK_Summary__c", "name"=>"New Field: MightySignal iOS SDK Summary"}
      mapping[IOS_RATINGS_COUNT] = {"id"=>"MightySignal_iOS_Ratings_Count__c", "name"=>"New Field: MightySignal iOS Ratings Count"}
    when 'android'
      mapping[ANDROID_PUB_ID] = {"id"=>"MightySignal_Android_Publisher_ID__c", "name"=>"New Field: MightySignal Android Publisher ID"}
      #mapping[GOOGLE_PLAY_PUB_ID] = {"id"=>"Google_Play_Publisher_ID__c", "name"=>"New Field: Google Play Publisher ID"}
      mapping[ANDROID_LINK] = {"id"=>"MightySignal_Android_Link__c", "name"=>"New Field: MightySignal Android Link"}
      mapping[ANDROID_SDK_SUMMARY] = {"id"=>"MightySignal_Android_SDK_Summary__c", "name"=>"New Field: MightySignal Android SDK Summary"}
      mapping[ANDROID_RATINGS_COUNT] = {"id"=>"MightySignal_Android_Ratings_Count__c", "name"=>"New Field: MightySignal Android Ratings Count"}
    end

    case @model_name
    when 'Account'
      mapping[PUBLISHER_NAME] = {"id"=>"Name", "name"=>"Name"}
    when 'Lead'
      mapping[PUBLISHER_NAME] = {"id"=>"Company", "name"=>"Company"}
    end

    mapping
  end

  def should_skip_field?(field, map, data, existing_object)

    default_fields = if account_import?
      ['Website', 'Name']
    else
      ['Website', 'Company']
    end

    if existing_object && default_fields.include?(map['id'])
      return existing_object[map['id']].present?
    end

    # skip if field is not on the right platform or no data is set
    data[field].blank? || (data[field][:data].blank? && map['data'].blank?)
  end

  def export(app: nil, mapping: nil, object_id: nil, publisher: nil, export_apps: true)

    app ||= publisher.apps.first if publisher
    publisher ||=  app.publisher if app

    return unless publisher

    initial_mapping = default_mapping(app: app, publisher: publisher).with_indifferent_access

    mapping = if mapping
      custom_mapping = JSON.parse(mapping).with_indifferent_access 
      custom_mapping = initial_mapping.merge(custom_mapping)
      custom_mapping
    else 
      initial_mapping 
    end

    update_default_mapping(mapping)

    data = data_fields(app: app, publisher: publisher)
    new_object = {}

    existing_object = @client.find(@model_name, object_id) if object_id

    mapping.each do |field, map|

      # Skip if is 
      next if should_skip_field?(field, map, data, existing_object)

      add_custom_field(@model_name, data[field].except(:data)) if data[field][:type]
      
      new_object[map["id"]] = if map['data']
        map['data']
      else
        data[field][:data]
      end
    end

    new_object = new_object.merge(new_object_fields(object_id))

    Throttler.new(@user.id, 25, 1.month, prefix: 'salesforce-user-export').increment if basic_access?

    puts "Import #{new_object.inspect}" if @logging 

    export = if object_id.present?
      @client.update!(@model_name, new_object)
      object_id
    else
      @client.create!(@model_name, new_object)
    end

    SalesforceLogger.new(@account, publisher, @model_name, object_id.blank?).send!

    if export_apps
      if app.is_a? IosApp
        SalesforceWorker.perform_async(:export_ios_apps, app.id, export, @user.id, @model_name)
      elsif app.is_a? AndroidApp
        SalesforceWorker.perform_async(:export_android_apps, app.id, export, @user.id, @model_name)
      end
    end

    export
  end

  def update_default_mapping(mapping)
    current_settings = @account.salesforce_settings.try(:with_indifferent_access) || {}
    current_settings[:default_object] = @model_name
    current_settings[:default_mapping] ||= {}

    # don't save mapping for input fields such as name, email, title on Leads
    new_mapping = mapping.reject {|k,v| v[:data].present?}

    current_settings[:default_mapping][@model_name] ||= {}
    current_settings[:default_mapping][@model_name].merge!(new_mapping)

    @account.salesforce_settings = current_settings
    @account.save
  end

  def import_ios_app(app:, account_id: nil)
    new_app = {
      'Name' => app.name,
      'MightySignal_App_ID__c' => app.id.to_s,
      'MightySignal_Key__c' => "ios#{app.id}",
      #'App_Store_ID__c' => app.app_identifier.to_s,
      'MightySignal_Link__c' => app.link(utm_source: 'salesforce'),
      'Platform__c' => 'ios',
      'Category__c' => app.categories.first,
      'SDK_Data__c' => sdk_display(app),
      'Mobile_Priority__c' => app.mobile_priority,
      'Ratings_Count__c' => app.total_rating_count,
      'User_Base__c' => app.international_userbase[:user_base],
      'Ad_Spend__c' => app.ad_spend?,
      'Release_Date__c' => app.release_date,
      'Last_Scanned_Date__c' => app.last_scanned.try(:to_date)
    }

    new_app['Account__c'] = account_id if account_id && account_import?

    @upsert_records[@app_model] ||= []
    unless @upsert_records[@app_model].any?{|app| app['MightySignal_Key__c'] == new_app['MightySignal_Key__c']}
      @upsert_records[@app_model] << new_app 
    end
  end

  def import_android_app(app:, account_id: nil)
    new_app = {
      'Name' => app.name,
      'MightySignal_App_ID__c' => app.id.to_s,
      'MightySignal_Key__c' => "android#{app.id}",
      #'App_Store_ID__c' => app.app_identifier.to_s,
      'MightySignal_Link__c' => app.link(utm_source: 'salesforce'),
      'Platform__c' => 'android',
      'Category__c' => app.categories.first,
      'SDK_Data__c' => sdk_display(app),
      'Mobile_Priority__c' => app.mobile_priority,
      'Ratings_Count__c' => app.ratings_all_count,
      'User_Base__c' => app.user_base,
      'Ad_Spend__c' => app.ad_spend?,
      'Last_Scanned_Date__c' => app.last_scanned.try(:to_date)
    }

    new_app['Account__c'] = account_id if account_id && account_import?

    @upsert_records[@app_model] ||= []
    unless @upsert_records[@app_model].any?{|app| app['MightySignal_Key__c'] == new_app['MightySignal_Key__c']}
      @upsert_records[@app_model] << new_app
    end
  end

  def import_app_ownership(app_id, export_id)
    new_app_ownership = {
      'MightySignal_Key__c' => app_id + export_id,
      'MightySignal_App__c' => app_id
    }

    if lead_import?
      new_app_ownership['Lead__c'] = export_id
    else
      new_app_ownership['Account__c'] = export_id
    end

    @upsert_records[@app_ownership_model] ||= []
    @upsert_records[@app_ownership_model] << new_app_ownership unless @upsert_records[@app_ownership_model].include?(new_app_ownership)
  end

  def import_publishers_apps(imports)
    @app_export_id_map = {}
    
    imports.each do |import|
      import = import.with_indifferent_access
      publisher = import[:publisher]
      export_id = import[:export_id]

      apps = publisher.apps
      if publisher.ios?
        apps = apps.joins(:app_stores_ios_apps).where.not(display_type: IosApp.display_types[:not_ios]).uniq
      else
        apps = apps.where.not(display_type: AndroidApp.display_types[:taken_down])
      end

      apps.limit(500).each do |app|
        app_key = "#{app.platform}_#{app.id}"
        @app_export_id_map[app_key] ||= []
        @app_export_id_map[app_key] << export_id
        if publisher.ios?
          import_ios_app(app: app, account_id: export_id)
        else
          import_android_app(app: app, account_id: export_id)
        end
      end
    end

    run_app_imports

    run_sdk_imports

    run_sdk_app_imports

    run_app_ownership_imports

    reset_bulk_data
  end

  def run_app_imports
    @sdk_app_map = {}
    results = @bulk_client.upsert(@app_model, @upsert_records[@app_model], 'MightySignal_Key__c', true)
    puts "App imports #{results.inspect}" if @logging 
    results['batches'].first['response'].each_with_index do |app, i|
      next unless app["id"] #record failed to import
      app_id = app["id"].first
      record = @upsert_records[@app_model][i]
      
      # leads use app ownership, accounts have id directly on app object
      # adjust will use app ownership on accounts as well (maybe all accounts in the future)
      if lead_import? || account_app_ownership?
        export_ids = @app_export_id_map["#{record['Platform__c']}_#{record['MightySignal_App_ID__c']}"]
        export_ids.each do |export_id|
          import_app_ownership(app_id, export_id)
        end
      end
      
      app = (record['Platform__c'] == 'ios') ? IosApp.find(record['MightySignal_App_ID__c']) : AndroidApp.find(record['MightySignal_App_ID__c'])

      sdk_response = app.tagged_sdk_response.with_indifferent_access

      sdk_response[:installed_sdks].each do |tag|
        next if should_skip_sdk_tag?(tag)
        tag[:sdks].each do |sdk|
          sdk_id = "#{app.platform}_#{sdk['id']}"
          import_sdk(platform: app.platform, sdk: sdk, category: tag.except(:sdks))
          @sdk_app_map[sdk_id] ||= []
          @sdk_app_map[sdk_id] << {app_id: app_id, installed: sdk['first_seen_date'].try(:to_date)}
        end
      end

      sdk_response[:uninstalled_sdks].each do |tag|
        next if should_skip_sdk_tag?(tag)
        tag[:sdks].each do |sdk|
          sdk_id = "#{app.platform}_#{sdk['id']}"
          import_sdk(platform: app.platform, sdk: sdk, category: tag.except(:sdks))
          @sdk_app_map[sdk_id] ||= []
          @sdk_app_map[sdk_id] << {app_id: app_id, uninstalled: sdk['last_seen_date'].try(:to_date)}
        end
      end
    end
  end

  def run_sdk_imports
    if @upsert_records[@sdk_model].present?
      results = @bulk_client.upsert(@sdk_model, @upsert_records[@sdk_model], 'MightySignal_Key__c', true)
      puts "SDK imports #{results.inspect}" if @logging 
      results['batches'].first['response'].each_with_index do |sdk, i|
        next unless sdk["id"] # failed to import

        sdk_id = sdk["id"].first
        record = @upsert_records[@sdk_model][i]

        sdk_apps = @sdk_app_map["#{record['Platform__c']}_#{record['MightySignal_SDK_ID__c']}"]
        sdk_apps.each do |sdk_app|
          sdk_app[:sdk_id] = sdk_id
          import_sdk_app(**sdk_app)
        end
      end
    end
  end

  def run_sdk_app_imports
    if @upsert_records[@sdk_join_model].try(:any?)
      @upsert_records[@sdk_join_model].each_slice(10_000) do |slice|
        results = @bulk_client.upsert(@sdk_join_model, slice, 'MightySignal_Key__c')
        puts "SDK app imports #{results.inspect}" if @logging 
      end
    end
  end

  def run_app_ownership_imports
    if @upsert_records[@app_ownership_model].try(:any?)
      @upsert_records[@app_ownership_model].each_slice(10_000) do |slice|
        results = @bulk_client.upsert(@app_ownership_model, slice, 'MightySignal_Key__c')
        puts "SDK app imports #{results.inspect}" if @logging 
      end
    end
  end

  def should_skip_sdk_tag?(tag)
    if @account.blacklisted_sdk_tags.present?
      return @account.blacklisted_sdk_tags.include? tag[:id]
    end

    false
  end

  def import_sdk(platform:, sdk:, category:)
    new_sdk = {
      'Name' => sdk['name'],
      'MightySignal_SDK_ID__c' => sdk['id'],
      'MightySignal_Key__c' => "#{platform}#{sdk['id']}",
      'MightySignal_Link__c' => "https://mightysignal.com/app/app#/sdk/ios/#{sdk['id']}",
      'Platform__c' => platform,
      'Website__c' => sdk['website'],
      'Category__c' => category[:name],
      'Category_ID__c' => category[:id]
    }
    
    @upsert_records[@sdk_model] ||= []
    @upsert_records[@sdk_model] << new_sdk unless @upsert_records[@sdk_model].include?(new_sdk)
  end

  def import_sdk_app(sdk_id:, app_id:, installed: nil, uninstalled: nil)
    new_sdk_app = {
      'MightySignal_Key__c' => app_id + sdk_id,
      'MightySignal_App__c' => app_id,
      'MightySignal_SDK__c' => sdk_id,
      'Installed__c' => installed,
      'Uninstalled__c' => uninstalled
    }
    
    @upsert_records[@sdk_join_model] ||= []
    @upsert_records[@sdk_join_model] << new_sdk_app unless @upsert_records[@sdk_join_model].include?(new_sdk_app)
  end

  def object_has_field?(model, field)
    @fields ||= {}
    @fields[model] ||= @client.describe(model)["fields"]
    @fields[model].each do |existing_field|
      return true if existing_field["name"] == field
    end
    false
  end

  def add_custom_field(model, field_options)
    field_options[:fullName] ||= "#{model}.#{salesforce_field(field_options[:label])}"

    return if object_has_field?(model, field_options[:fullName].split('.').last)

    @metadata_client.create(:custom_field, 
      field_options
    ).on_complete{|job|
      update_field_permissions(field_options[:fullName])
    }.on_error{|job|
      update_field_permissions(field_options[:fullName])
    }.perform
  end

  def update_field_permissions(field_full_name)
    @profiles ||= @metadata_client.list_metadata(:profile)
    @profiles.in_groups_of(10) {|group|
      metadata = group.compact.map{|profile| {fullName: profile["full_name"], 
                                      fieldPermissions: [{field: field_full_name, 
                                                          editable: true, 
                                                          readable: true,
                                                         }]
                                     }}
      @metadata_client.update_metadata(:profile, metadata)
    }
  end

  def self.sf_for(account_name, model_name = 'Account', logging = false)
    account = Account.where(name: account_name).first
    SalesforceExportService.new(user: account.users.first, model_name: model_name, logging: logging)
  end

  def sync_domain_mapping(models: supported_models, date: nil, queue: :salesforce_syncer)
    dl = DomainLinker.new
    models.each do |model|
      @model_name = model
      model_query = @account.domain_mapping_query(model)
      custom_website_fields = @account.custom_website_fields(model)

      select_fields = "Id, Website, MightySignal_iOS_Publisher_ID__c, MightySignal_Android_Publisher_ID__c"
      website_filter = " and Website != null"

      if custom_website_fields.present?
        select_fields += ", " + custom_website_fields.join(', ') 
        website_filter = " and (Website != null or #{custom_website_fields.join(' != null or ')} != null)"
      end

      query = "select #{select_fields} from #{model} where (MightySignal_iOS_Publisher_ID__c = null or MightySignal_Android_Publisher_ID__c = null)"
      query += website_filter
      query += " and #{model_query}" if model_query
      query += " and IsConverted = false" if model == 'Lead'
      query += " and CreatedDate > #{date}" if date

      imports = []

      @client.query(query).each do |record|
        record_id = record.Id
        new_record = {Id: record_id}

        website = if custom_website_fields.present?
          (custom_website_fields + ['Website']).map{|field| record[field]}.compact.first
        else
          record.Website
        end

        domain = UrlHelper.url_with_domain_only(website)
        publishers = dl.domain_to_publisher(domain)
        ios_publisher = publishers.select{|pub| pub.class.name == 'IosDeveloper'}.first
        android_publisher = publishers.select{|pub| pub.class.name == 'AndroidDeveloper'}.first
        if !record.MightySignal_iOS_Publisher_ID__c && ios_publisher
          new_record[:MightySignal_iOS_Publisher_ID__c] = ios_publisher.id
          imports << {publisher_id: ios_publisher.id, platform: 'ios', export_id: record_id}

          SalesforceWorker.set(queue: queue).perform_async(:export_ios_publisher, ios_publisher.id, record_id, @user.id, @model_name) if date
        end

        if !record.MightySignal_Android_Publisher_ID__c && android_publisher
          new_record[:MightySignal_Android_Publisher_ID__c] = android_publisher.id
          imports << {publisher_id: android_publisher.id, platform: 'android', export_id: record_id}

          SalesforceWorker.set(queue: queue).perform_async(:export_android_publisher, android_publisher.id, record_id, @user.id, @model_name) if date
        end

        puts "Domain is #{domain}"
        puts new_record if new_record.size > 1

        @update_records[model] ||= []
        @update_records[model] << new_record if new_record.size > 1
      end

      if @update_records[model].try(:any?) && date.blank?
        @update_records[model].each_slice(10_000) do |slice|
          @bulk_client.update(model, slice)
        end
      end

      if date
        imports.each_slice(100).with_index do |slice, i|
          SalesforceWorker.set(queue: queue).perform_async(:export_publishers_apps, slice, @user.id, model)
        end
      end
    end
    reset_bulk_data
  end

  def basic_access?
    @account.salesforce_tier == 'basic'
  end

  private

  IOS_PUB_ID = "MightySignal iOS Publisher ID"
  ANDROID_PUB_ID = "MightySignal Android Publisher ID"
  #APP_STORE_PUB_ID = "App Store Publisher ID"
  #GOOGLE_PLAY_PUB_ID = "Google Play Publisher ID"
  IOS_LINK = "MightySignal iOS Link"
  ANDROID_LINK = "MightySignal Android Link"
  PUBLISHER_NAME = "Publisher Name"
  WEBSITE = "Website"
  IOS_SDK_SUMMARY = "MightySignal iOS SDK Summary"
  ANDROID_SDK_SUMMARY = "MightySignal Android SDK Summary"
  LAST_SYNCED = "MightySignal Last Synced"
  ANDROID_RATINGS_COUNT = "MightySignal Android Ratings Count"
  IOS_RATINGS_COUNT = "MightySignal iOS Ratings Count"

  def data_fields(app: nil, publisher: nil)
    fields = { 
      PUBLISHER_NAME => {length: 255, type: 'Text', label: "MightySignal Publisher Name"},
      WEBSITE => {length: 255, type: 'Text', label: "MightySignal Publisher Website"},
      IOS_PUB_ID => {type: 'Text', label: "MightySignal iOS Publisher ID", length: 255},
      #APP_STORE_PUB_ID => {length: 255, type: 'Text', label: "App Store Publisher ID"},
      IOS_LINK => {type: 'Url', label: "MightySignal iOS Link"},
      IOS_SDK_SUMMARY => {length: 131072, type: 'LongTextArea', visibleLines: 10, label: "MightySignal iOS SDK Summary"},
      ANDROID_PUB_ID => {length: 255, type: 'Text', label: "MightySignal Android Publisher ID"},
      #GOOGLE_PLAY_PUB_ID => {length: 255, type: 'Text', label: "Google Play Publisher ID"},
      ANDROID_LINK => {type: 'Url', label: "MightySignal Android Link"},
      ANDROID_SDK_SUMMARY => {length: 131072, type: 'LongTextArea', visibleLines: 10, label: "MightySignal Android SDK Summary"},
      LAST_SYNCED => {type: 'Date', label: 'MightySignal Last Synced'},
      IOS_RATINGS_COUNT => {type: 'Number', label: 'MightySignal iOS Ratings Count', precision: 18, scale: 0},
      ANDROID_RATINGS_COUNT => {type: 'Number', label: 'MightySignal Android Ratings Count', precision: 18, scale: 0}
    }

    publisher ||= app.try(:publisher)

    if publisher
      case publisher.platform.to_s
      when 'ios'
        fields[IOS_PUB_ID][:data] = publisher.try(:id)
        #fields[APP_STORE_PUB_ID][:data] = app.ios_developer.try(:identifier)
        fields[IOS_LINK][:data] = publisher.try(:link, utm_source: 'salesforce')
        fields[PUBLISHER_NAME][:data] = publisher.try(:name) || app.try(:name)
        fields[WEBSITE][:data] = publisher.try(:valid_websites).try(:first).try(:url)
        fields[IOS_SDK_SUMMARY][:data] = developer_sdk_summary(publisher)
        fields[IOS_RATINGS_COUNT][:data] = publisher.ratings_all_count
      when 'android'
        fields[ANDROID_PUB_ID][:data] = publisher.try(:id)
        #fields[GOOGLE_PLAY_PUB_ID][:data] = app.android_developer.try(:identifier)
        fields[ANDROID_LINK][:data] = publisher.try(:link, utm_source: 'salesforce')
        fields[PUBLISHER_NAME][:data] = publisher.try(:name) || app.try(:name)
        fields[WEBSITE][:data] = publisher.try(:valid_websites).try(:first).try(:url)
        fields[ANDROID_SDK_SUMMARY][:data] = developer_sdk_summary(publisher)
        fields[ANDROID_RATINGS_COUNT][:data] = publisher.ratings_all_count
      end

      fields[LAST_SYNCED][:data] = Date.today

      if @model_name == 'Lead'
        fields['Title'] = {label: 'Title'}
        fields['Email'] = {label: 'Email'}
        fields['Last Name'] = {label: 'Last Name'}
        fields['First Name'] = {label: 'First Name'}
      end
    end

    fields
  end

  def reset_bulk_data
    @upsert_records = {}
    @create_records = {}
    @update_records = {}
  end

  def supported_models
    ['Account', 'Lead']
  end

  def new_object_fields(object_id)
    fields = {}
    # only set these fields if this is a new record
    if object_id.blank?
      fields['OwnerId'] = @user.salesforce_uid if @user.salesforce_uid.present?

      case @model_name
      when 'Account'
        fields['AccountSource'] = 'MightySignal' if object_has_field?(@model_name, 'AccountSource')
      when 'Lead'
        fields['LeadSource'] = 'MightySignal' if object_has_field?(@model_name, 'LeadSource')
      end
    else
      fields['Id'] = object_id
    end

    fields
  end

  def sdk_display(app)
    return "App has not been scanned before" unless app.last_scanned

    text = "<h1 #{h1_css}>Installed SDKs</h1>"
    sdk_response = app.tagged_sdk_response
    if sdk_response[:installed_sdks].any?
      sdk_response[:installed_sdks].each do |tag|
        text += "<p #{tag_css}>#{tag[:name]}</p><ul #{list_css}>"
        tag[:sdks].each do |sdk|
          text += "<li><img #{image_css} src='#{sdk['favicon']}' width='16' height='16' /> #{sdk['name']} - <span #{installed_css}>Installed #{sdk['first_seen_date'].to_date.to_s}</span></li>"
        end
        text += "</ul>"
      end
    else
      text += "No Installed SDKs\n"
    end
    text += "<h1 #{h1_css}>Uninstalled SDKs</h1>"
    if sdk_response[:uninstalled_sdks].any?
      sdk_response[:uninstalled_sdks].each do |tag|
        text += "<p #{tag_css}>#{tag[:name]}</p><ul #{list_css}>"
        tag[:sdks].each do |sdk|
          text += "<li><img #{image_css} src='#{sdk['favicon']}' width='16' height='16' /> #{sdk['name']} - <span #{uninstalled_css}>Uninstalled #{sdk['last_seen_date'].to_date.to_s}</span></li>"
        end
        text += "</ul>"
      end
    else
      text += "No Uninstalled SDKs\n"
    end
    text
  end

  def developer_sdk_summary(developer)
    return unless developer

    tagged_sdk_summary = developer.tagged_sdk_summary
    text = ""
    tagged_sdk_summary.each do |k,v|
      text += "<h1 #{h1_css}>#{k.to_s.split('_').join(' ').titleize}</h1>"
      v.each do |tag, sdks|
        text += "<p #{tag_css}>#{tag}</p><ul #{list_css}>"
        sdks.each do |sdk|
          text += "<li><img #{image_css} src='#{sdk[:favicon]}' width='16' height='16' /> #{sdk[:name]} - #{sdk[:count]} Apps</li>"
        end
        text += "</ul>"
      end
    end
    text
  end

  def h1_css
    "style='font-size: 14px;color:#3F4245;font-weight: 700;'"
  end

  def tag_css
    "style='color: #767676;'"
  end

  def installed_css
    "style='color: green;'"
  end

  def uninstalled_css
    "style='color: red;'"
  end

  def image_css
    "style='margin-right: 5px;'"
  end

  def list_css
    "style='list-style: none;'"
  end

  def salesforce_field(human_name)
    "#{human_name.gsub(' ', '_')}__c"
  end

  def refresh_token(response)
    @user.account.update_attributes(salesforce_token: response["access_token"])
  end

  def account_import?
    @model_name == 'Account'
  end

  def lead_import?
    @model_name == 'Lead'
  end

  def update_metadata_token(client, options)
    @client.authenticate!
    options[:session_id] = @client.options[:oauth_token]
  end

end
