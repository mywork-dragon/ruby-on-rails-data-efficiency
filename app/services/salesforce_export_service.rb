class SalesforceExportService
  attr_reader :client, :metadata_client

  def initialize(user:, model_name: 'Account')
    @user = user
    account = @user.account
    @model_name = model_name

    Restforce.log = true
    @client ||= Restforce.new(
      oauth_token: account.salesforce_token,
      refresh_token: account.salesforce_refresh_token,
      authentication_callback: method(:refresh_token),
      instance_url: account.salesforce_instance_url,
      client_id: '3MVG9i1HRpGLXp.pUhSTB.tZbHDa3jGq5LTNGRML_QgvmjyWLmLUJVgg4Mgly3K_uil7kNxjFa0jOD54H3Ex9',
      client_secret: ENV['SALESFORCE_AUTH_CLIENT_SECRET'],
      api_version: '39.0'
    )
    @metadata_client ||= Metaforce.new(
                          session_id: account.salesforce_token, 
                          authentication_handler: method(:update_metadata_token),
                          metadata_server_url: "#{account.salesforce_instance_url}/services/Soap/m/30.0", 
                          server_url: "#{account.salesforce_instance_url}/services/Soap/m/30.0"
                        )
  end

  def install
    @metadata_client.create(:custom_object, 
      full_name: 'App__c', 
      deploymentStatus: 'Deployed',
      sharingModel: 'ReadWrite',
      label: 'App', 
      pluralLabel: 'Apps',
      nameField: {
        label: 'App Name',
        type: 'Text'
      }
    ).on_complete { |job|
      create_app_fields
    }.on_error {|job|
      create_app_fields
    }.perform
  end

  def create_app_fields
    puts 'create app fields'
    new_fields = [
      {label: 'MightySignal App ID', type: 'Text', length: 255, externalId: true},
      {label: 'App Store/Google Play App ID', fullName: 'App__c.App_Store_ID__c', type: 'Text', length: 255},
      {label: 'MightySignal Link', type: 'Url'},
      {label: 'Platform', type: 'Text', length: 255},
      {label: 'SDK Data', type: 'RichTextArea', length: 131072, visibleLines: 10},
      {label: 'Mobile Priority', type: 'Text', length: 255},
      {label: 'User Base', type: 'Text', length: 255},
      {label: 'Monthly Active Users', type: 'Number', precision: 11, scale: 0},
      {label: 'Weekly Active Users', type: 'Number', precision: 11, scale: 0},
      {label: 'Daily Active Users', type: 'Number', precision: 11, scale: 0},
      {label: 'Ad Spend', type: 'Checkbox', defaultValue: false},
      {label: 'Release Date', type: 'Date'},
      {label: 'Last Scanned Date', type: 'Date'},
      {label: 'Account Name', type: 'Lookup', fullName: 'App__c.Account__c', referenceTo: 'Account', relationshipName: 'Apps'}
    ]
    new_fields.each do |field|
      add_custom_field('App__c', field)
    end
  end

  def uninstall
    @metadata_client.delete(:custom_object, 
      'App__c', 
    ).on_complete { |job| puts "Custom object deleted." }.perform
  end

  def search(query)
    search_queries = {
      Account: "select Id, Name from Account where Name LIKE '%#{query}%'",
      Lead: "select Id, Company, FirstName, LastName, Title from Lead where Company LIKE '%#{query}%'",
      Opportunity: "select Account.Id, Account.Name from Opportunity where Account.Name LIKE #{query}",
    }.with_indifferent_access

    puts "Query is #{query} #{search_queries[@model_name]}"

    results = @client.query(search_queries[@model_name])
    results = results.map{|result|
      name = case @model_name
      when 'Account'
        result.Name
      when 'Lead'
        "#{result.FirstName} #{result.LastName} - #{result.Title}\n#{result.Company}"
      end
      {name: name, id: result.Id}
    }
    results
  end

  def export_app(app:, mapping:, object_id:)
    mapping = JSON.parse(mapping).with_indifferent_access if mapping
    update_default_mapping(mapping)

    data = data_fields(app)
    new_object = {}

    mapping.each do |field, map|
      if !object_has_field?(map["id"])
        add_custom_field(@model_name, data[field].except(:data))
      end
      new_object[map["id"]] = if map['data']
        map['data']
      else
        puts "Field is #{field} #{data}"
        data[field][:data]
      end
    end

    new_object = new_object.merge(new_object_fields(object_id))

    export = if object_id.present?
      @client.update(@model_name, new_object)
      object_id
    else
      @client.create(@model_name, new_object)
    end

    puts "Export id is #{export}"

    # apps only belong to accounts for now
    if @model_name == 'Account'
      if app.is_a? IosApp
        app.ios_developer.ios_apps.each do |app|
          import_ios_app(app: app, account_id: export)
        end
      elsif app.is_a? AndroidApp
        app.android_developer.android_apps.each do |app|
          import_android_app(app: app, account_id: export)
        end
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
    puts new_app
    @client.upsert('App__c', 'MightySignal_App_ID__c', new_app)
  end

  def import_android_app(app:, account_id:)
    new_app = {
      'Name' => app.name,
      'MightySignal_App_ID__c' => app.id.to_s,
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
    @client.upsert('App__c', 'MightySignal_App_ID__c', new_app)
  end

  def object_has_field?(field)
    @fields ||= @client.describe(@model_name)["fields"]
    @fields.each do |existing_field|
      return true if existing_field["name"] == field
    end
    false
  end

  def add_custom_field(model, field_options)
    field_options[:fullName] ||= "#{model}.#{salesforce_field(field_options[:label])}"
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

  private

  def data_fields(app)
    case app.platform
    when 'ios'
      {
        "MightySignal Publisher ID" => {data: app.ios_developer.try(:id), length: 255, type: 'Text', label: "MightySignal Publisher ID"},
        "App Store Publisher ID" => {data: app.ios_developer.try(:identifier), length: 255, type: 'Text', label: "App Store Publisher ID"},
        "MightySignal Link" => {data: app.ios_developer.try(:link, utm_source: 'salesforce'), type: 'Url', label: "MightySignal Link"},
        "Publisher Name" => {data: app.ios_developer.try(:name) || app.name, length: 255, type: 'Text', label: "MightySignal Publisher Name"},
        "Website" => {data: app.ios_developer.try(:valid_websites).try(:first).try(:url), length: 255, type: 'Text', label: "MightySignal Publisher Website"},
        "SDK Summary" => {data: developer_sdk_summary(app.ios_developer), length: 131072, type: 'RichTextArea', visibleLines: 10, label: "MightySignal SDK Summary"}
      }
    when 'android'
      {
        "MightySignal Publisher ID" => {data: app.android_developer.try(:id), length: 255, type: 'Text', label: "MightySignal Publisher ID"},
        "Google Play Publisher ID" => {data: app.android_developer.try(:identifier), length: 255, type: 'Text', label: "Google Play Publisher ID"},
        "MightySignal Link" => {data: app.android_developer.try(:link, utm_source: 'salesforce'), type: 'Url', label: "MightySignal Link"},
        "Publisher Name" => {data: app.android_developer.try(:name) || app.name, length: 255, type: 'Text', label: "MightySignal Publisher Name"},
        "Website" => {data: app.android_developer.try(:valid_websites).try(:first).try(:url), length: 255, type: 'Text', label: "MightySignal Publisher Website"},
        "SDK Summary" => {data: developer_sdk_summary(app.android_developer), length: 131072, type: 'RichTextArea', visibleLines: 10, label: "MightySignal SDK Summary"}
      }
    end
  end

  def new_object_fields(object_id)
    fields = {}
    # only set these fields if this is a new record
    if object_id.blank?
      fields['OwnerId'] = @user.salesforce_uid if @user.salesforce_uid.present?

      case @model_name
      when 'Account'
        fields['AccountSource'] = 'MightySignal'
      when 'Lead'
        fields['LeadSource'] = 'MightySignal'
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
    puts "Did try to get refresh token #{response["access_token"]}"
    @user.account.update_attributes(salesforce_token: response["access_token"])
  end

  def update_metadata_token(client, options)
    @client.authenticate!
    options[:session_id] = @client.options[:oauth_token]
  end

end
