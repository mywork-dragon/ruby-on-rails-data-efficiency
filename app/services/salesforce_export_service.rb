class SalesforceExportService
  attr_reader :client, :metadata_client, :bulk_client

  def initialize(user:, model_name: 'Account')
    @user = user
    @account = @user.account
    @model_name = model_name
    @is_sandbox = @account.salesforce_settings.with_indifferent_access[:is_sandbox]

    @app_model = 'MightySignal_App__c'
    @sdk_model = 'MightySignal_SDK__c'
    @sdk_join_model = 'MightySignal_SDK_App__c'

    client_id = '3MVG9i1HRpGLXp.pUhSTB.tZbHDa3jGq5LTNGRML_QgvmjyWLmLUJVgg4Mgly3K_uil7kNxjFa0jOD54H3Ex9'

    Restforce.log = true

    host = @is_sandbox ? 'test.salesforce.com' : 'login.salesforce.com'

    @client ||= Restforce.new(
      oauth_token: @account.salesforce_token,
      refresh_token: @account.salesforce_refresh_token,
      authentication_callback: method(:refresh_token),
      instance_url: @account.salesforce_instance_url,
      client_id: client_id,
      client_secret: ENV['SALESFORCE_AUTH_CLIENT_SECRET'],
      api_version: '39.0',
      host: host
    )
    @metadata_client ||= Metaforce.new(
                          session_id: @account.salesforce_token, 
                          authentication_handler: method(:update_metadata_token),
                          metadata_server_url: "#{@account.salesforce_instance_url}/services/Soap/m/30.0", 
                          server_url: "#{@account.salesforce_instance_url}/services/Soap/m/30.0",
                          host: host
                        )
    @bulk_client = SalesforceBulkApi::Api.new(@client)

    @upsert_records = {}
    @create_records = {}
    @update_records = {}
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

    create_main_fields

    @account.update_attributes(salesforce_status: :ready)
  end

  def sync_all_objects
    supported_models.each do |model|
      @model_name = model
      @client.query("select Id, MightySignal_iOS_Publisher_ID__c, MightySignal_Android_Publisher_ID__c from #{model} where MightySignal_iOS_Publisher_ID__c != null or MightySignal_Android_Publisher_ID__c != null").each do |object|
        if object.MightySignal_iOS_Publisher_ID__c
          ios_publisher = IosDeveloper.find(object.MightySignal_iOS_Publisher_ID__c)
          export(publisher: ios_publisher, object_id: object.Id)
        end
        if object.MightySignal_Android_Publisher_ID__c
          android_publisher = AndroidDeveloper.find(object.MightySignal_Android_Publisher_ID__c)
          export(publisher: android_publisher, object_id: object.Id)
        end
      end
    end
  end

  def create_app_fields
    puts 'create app fields'
    new_fields = [
      {label: 'MightySignal App ID', type: 'Text', length: 255},
      {label: 'MightySignal Key', type: 'Text', length: 255, externalId: true},
      #{label: 'App Store/Google Play App ID', fullName: "#{@app_model}.App_Store_ID__c", type: 'Text', length: 255},
      {label: 'MightySignal Link', type: 'Url'},
      {label: 'Platform', type: 'Text', length: 255},
      {label: 'SDK Data', type: 'LongTextArea', length: 131072, visibleLines: 10},
      {label: 'Mobile Priority', type: 'Text', length: 255},
      {label: 'User Base', type: 'Text', length: 255},
      {label: 'Monthly Active Users', type: 'Number', precision: 11, scale: 0},
      {label: 'Weekly Active Users', type: 'Number', precision: 11, scale: 0},
      {label: 'Daily Active Users', type: 'Number', precision: 11, scale: 0},
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
    puts 'create sdk fields'
    new_fields = [
      {label: 'MightySignal SDK ID', type: 'Text', length: 255},
      {label: 'MightySignal Key', type: 'Text', length: 255, externalId: true},
      {label: 'MightySignal Link', type: 'Url'},
      {label: 'Website', type: 'Url'},
      {label: 'Platform', type: 'Text', length: 255},
      {label: 'Category', type: 'Picklist', picklist: {picklistValues: [{fullName: 'Analytics'}]}}
    ]
    new_fields.each do |field|
      add_custom_field(@sdk_model, field)
    end
  end

  def create_sdkapp_fields
    puts 'create sdkapp fields'
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

  def create_main_fields
    supported_models.each do |model|
      fields = data_fields
      fields.each do |field_key, field|
        add_custom_field(model, field)
      end
    end
  end

  def uninstall
    @metadata_client.delete(:custom_object, 
      @app_model, 
    ).on_complete { |job| puts "Custom object deleted." }.perform
  end

  def search(query)
    search_queries = {
      Account: "select Id, Name from Account where Name LIKE '%#{query}%'",
      Lead: "select Id, Company, FirstName, LastName, Title, Email from Lead where Company LIKE '%#{query}%'",
      Opportunity: "select Account.Id, Account.Name from Opportunity where Account.Name LIKE #{query}",
    }.with_indifferent_access

    puts "Query is #{query} #{search_queries[@model_name]}"

    results = @client.query(search_queries[@model_name])
    results = results.map{|result|
      object = {}
      case @model_name
      when 'Account'
        object[:name] = result.Name
      when 'Lead'
        object[:name] = "#{result.FirstName} #{result.LastName} - #{result.Title}\n#{result.Company}"
        object[:title] = result.Title
        object[:first_name] = result.FirstName
        object[:last_name] = result.LastName
        object[:email] = result.Email
      end

      object[:id] = result.Id
      object
    }
    results
  end

  def default_mapping(app)
    mapping = {}
    mapping[WEBSITE] = {"id"=>"Website", "name"=>"Website"}

    case app.platform
    when 'ios'
      mapping[IOS_PUB_ID] = {"id"=>"MightySignal_iOS_Publisher_ID__c", "name"=>"New Field: MightySignal iOS Publisher ID"}
      #mapping[APP_STORE_PUB_ID] = {"id"=>"App_Store_Publisher_ID__c", "name"=>"New Field: App Store Publisher ID"}
      mapping[IOS_LINK] = {"id"=>"MightySignal_iOS_Link__c", "name"=>"New Field: MightySignal iOS Link"}
      mapping[IOS_SDK_SUMMARY] = {"id"=>"MightySignal_iOS_SDK_Summary__c", "name"=>"New Field: MightySignal iOS SDK Summary"}
    when 'android'
      mapping[ANDROID_PUB_ID] = {"id"=>"MightySignal_Android_Publisher_ID__c", "name"=>"New Field: MightySignal Android Publisher ID"}
      #mapping[GOOGLE_PLAY_PUB_ID] = {"id"=>"Google_Play_Publisher_ID__c", "name"=>"New Field: Google Play Publisher ID"}
      mapping[ANDROID_LINK] = {"id"=>"MightySignal_Android_Link__c", "name"=>"New Field: MightySignal Android Link"}
      mapping[ANDROID_SDK_SUMMARY] = {"id"=>"MightySignal_Android_SDK_Summary__c", "name"=>"New Field: MightySignal Android SDK Summary"}
    end

    case @model_name
    when 'Account'
      mapping[PUBLISHER_NAME] = {"id"=>"Name", "name"=>"Name"}
    when 'Lead'
      mapping[PUBLISHER_NAME] = {"id"=>"Company", "name"=>"Company"}
    end

    mapping
  end

  def should_skip_field?(field, map, data, object_id)
    default_fields = if @model_name == 'Account'
      ['Website', 'Name']
    else
      ['Website', 'Company']
    end

    if object_id && default_fields.include?(map['id'])
      existing_object = @client.find(@model_name, object_id) 
      return existing_object[map['id']].present?
    end

    # skip if field is not on the right platform or no data is set
    data[field].blank? || (data[field][:data].blank? && map['data'].blank?)
  end

  def export(app: nil, mapping: nil, object_id: nil, publisher: nil)
    app = publisher.apps.first if publisher
    
    mapping = if mapping
      JSON.parse(mapping).with_indifferent_access 
    else
      default_mapping(app).with_indifferent_access 
    end

    update_default_mapping(mapping)

    data = data_fields(app)
    new_object = {}

    mapping.each do |field, map|
      puts "Field is #{field} #{data}"

      # Skip if is 
      next if should_skip_field?(field, map, data, object_id)
      
      add_custom_field(@model_name, data[field].except(:data))
      
      new_object[map["id"]] = if map['data']
        map['data']
      else
        data[field][:data]
      end
    end

    new_object = new_object.merge(new_object_fields(object_id))

    puts "Publisher to export #{@model_name} #{new_object.to_json}"

    export = if object_id.present?
      @client.update!(@model_name, new_object)
      object_id
    else
      @client.create!(@model_name, new_object)
    end

    puts "Export id is #{export}"

    # apps only belong to accounts for now, run in background job
    if @model_name == 'Account'
      if app.is_a? IosApp
        SalesforceWorker.perform_async(:export_ios_apps, app.id, export, @user.id, @model_name)
      elsif app.is_a? AndroidApp
        SalesforceWorker.perform_async(:export_android_apps, app.id, export, @user.id, @model_name)
      end
    end

    export
  end

  def update_default_mapping(mapping)
    account = @user.account
    current_settings = account.salesforce_settings.try(:with_indifferent_access) || {}
    current_settings[:default_object] = @model_name
    current_settings[:default_mapping] ||= {}

    # don't save mapping for input fields such as name, email, title on Leads
    new_mapping = mapping.reject {|k,v| v[:data].present?}

    current_settings[:default_mapping][@model_name] ||= {}
    current_settings[:default_mapping][@model_name].merge!(new_mapping)

    account.salesforce_settings = current_settings
    account.save
  end

  def import_ios_app(app:, account_id:)
    new_app = {
      'Name' => app.name,
      'MightySignal_App_ID__c' => app.id.to_s,
      'MightySignal_Key__c' => "ios#{app.id}",
      'App_Store_ID__c' => app.app_identifier.to_s,
      'MightySignal_Link__c' => app.link(utm_source: 'salesforce'),
      'Platform__c' => 'ios',
      'SDK_Data__c' => sdk_display(app),
      'Mobile_Priority__c' => app.mobile_priority,
      'User_Base__c' => app.international_userbase[:user_base],
      'Monthly_Active_Users__c' => app.monthly_active_users,
      'Daily_Active_Users__c' => app.daily_active_users,
      'Weekly_Active_Users__c' => app.weekly_active_users,
      'Ad_Spend__c' => app.ad_spend?,
      'Release_Date__c' => app.release_date,
      'Last_Scanned_Date__c' => app.last_scanned.try(:to_date),
      'Account__c' => account_id
    }

    import_app(new_app: new_app, app: app)
  end

  def import_android_app(app:, account_id:)
    new_app = {
      'Name' => app.name,
      'MightySignal_App_ID__c' => app.id.to_s,
      'MightySignal_Key__c' => "android#{app.id}",
      'App_Store_ID__c' => app.app_identifier.to_s,
      'MightySignal_Link__c' => app.link(utm_source: 'salesforce'),
      'Platform__c' => 'android',
      'SDK_Data__c' => sdk_display(app),
      'Mobile_Priority__c' => app.mobile_priority,
      'User_Base__c' => app.user_base,
      'Ad_Spend__c' => app.old_ad_spend?,
      'Last_Scanned_Date__c' => app.last_scanned.try(:to_date),
      'Account__c' => account_id
    }

    import_app(new_app: new_app, app: app)
  end

  def import_app(new_app: , app:)
    sf_app = @client.query("select Id from #{@app_model} where MightySignal_Key__c = '#{app.platform}#{app.id.to_s}'").first
    app_id = if sf_app
      new_app['Id'] = sf_app.Id
      @client.update!(@app_model, new_app)
      sf_app.Id
    else
      @client.create!(@app_model, new_app)
    end

    sdk_response = app.tagged_sdk_response

    sdk_response[:installed_sdks].each do |tag|
      tag[:sdks].each do |sdk|
        sdk_id = import_sdk(platform: app.platform, sdk: sdk, category: tag[:name])
        import_sdk_app(sdk_id: sdk_id, app_id: app_id, installed: sdk['first_seen_date'].try(:to_date))
      end
    end

    sdk_response[:uninstalled_sdks].each do |tag|
      tag[:sdks].each do |sdk|
        sdk_id = import_sdk(platform: app.platform, sdk: sdk, category: tag[:name])
        import_sdk_app(sdk_id: sdk_id, app_id: app_id, uninstalled: sdk['last_seen_date'].try(:to_date))
      end
    end

    @bulk_client.upsert(@sdk_join_model, @upsert_records[@sdk_join_model], 'MightySignal_Key__c')

    app_id
  end

  def import_sdk(platform:, sdk:, category:)
    new_sdk = {
      'Name' => sdk['name'],
      'MightySignal_SDK_ID__c' => sdk['id'],
      'MightySignal_Key__c' => "#{platform}#{sdk['id']}",
      'MightySignal_Link__c' => "https://mightysignal.com/app/app#/sdk/ios/#{sdk['id']}",
      'Platform__c' => platform,
      'Website__c' => sdk['website'],
      'Category__c' => category
    }
    sf_sdk = @client.query("select Id from #{@sdk_model} where MightySignal_Key__c = '#{platform}#{sdk['id']}'").first
    if sf_sdk
      new_sdk['Id'] = sf_sdk.Id
      @client.update!(@sdk_model, new_sdk)
      sf_sdk.Id
    else
      @client.create!(@sdk_model, new_sdk)
    end
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
    @upsert_records[@sdk_join_model] << new_sdk_app
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
    puts "Add custom field #{field_options[:fullName]}"

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

  def self.sf_for(account_name)
    account = Account.where(name: account_name).first
    SalesforceExportService.new(user: account.users.first)
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

  def data_fields(app=nil)
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
      ANDROID_SDK_SUMMARY => {length: 131072, type: 'LongTextArea', visibleLines: 10, label: "MightySignal Android SDK Summary"}
    }  
    if app
      case app.platform
      when 'ios'
        fields[IOS_PUB_ID][:data] = app.ios_developer.try(:id)
        #fields[APP_STORE_PUB_ID][:data] = app.ios_developer.try(:identifier)
        fields[IOS_LINK][:data] = app.ios_developer.try(:link, utm_source: 'salesforce')
        fields[PUBLISHER_NAME][:data] = app.ios_developer.try(:name) || app.name
        fields[WEBSITE][:data] = app.ios_developer.try(:valid_websites).try(:first).try(:url)
        fields[IOS_SDK_SUMMARY][:data] = developer_sdk_summary(app.ios_developer)
      when 'android'
        fields[ANDROID_PUB_ID][:data] = app.android_developer.try(:id)
        #fields[GOOGLE_PLAY_PUB_ID][:data] = app.android_developer.try(:identifier)
        fields[ANDROID_LINK][:data] = app.android_developer.try(:link, utm_source: 'salesforce')
        fields[PUBLISHER_NAME][:data] = app.android_developer.try(:name) || app.name
        fields[WEBSITE][:data] = app.android_developer.try(:valid_websites).try(:first).try(:url)
        fields[ANDROID_SDK_SUMMARY][:data] = developer_sdk_summary(app.android_developer)
      end
    end

    fields
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
    puts "Did try to get refresh token"
    @user.account.update_attributes(salesforce_token: response["access_token"])
  end

  def update_metadata_token(client, options)
    @client.authenticate!
    options[:session_id] = @client.options[:oauth_token]
  end

end
