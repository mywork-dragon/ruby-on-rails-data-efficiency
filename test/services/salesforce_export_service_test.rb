require 'test_helper'
require 'mocha/mini_test'

class SalesforceExportServiceTest < ActiveSupport::TestCase

  def setup 
    salesforce_token = 'wadawdjkawdjkawjd'
    salesforce_refresh_token = 'awdawdowadjiow'

    @account = Account.create!(
      name: 'MightySignal', 
      salesforce_token: salesforce_token, 
      salesforce_refresh_token: salesforce_refresh_token,
      salesforce_uid: '0050a00000ForTZAAZ',
      salesforce_settings: {"is_sandbox"=>true},
      salesforce_instance_url: 'https://cs17.salesforce.com',
    ) 

    @account2 = Account.create!(
      name: 'Adjust', 
      salesforce_token: salesforce_token, 
      salesforce_refresh_token: salesforce_refresh_token,
      salesforce_uid: '0050a00000ForTZAAZ',
      salesforce_settings: {"is_sandbox"=>true, 'custom_website_fields' => {'Lead' => ['Email_Domain__c']}},
      salesforce_instance_url: 'https://cs17.salesforce.com',
    ) 

    @user = User.create!(account_id: @account.id, email: 'matt@mightysignal.com', password: '12345')
    @user2 = User.create!(account_id: @account2.id, email: 'bob@mightysignal.com', password: '12345')

    @sf = SalesforceExportService.sf_for('MightySignal')
    @sf2 = SalesforceExportService.sf_for('Adjust')

    @ios_developer = IosDeveloper.create!(name: '3 Comma Studio LLC', identifier: '12345')
    @android_developer = AndroidDeveloper.create!(name: '3 Comma Studio LLC', identifier: '12345')

    @ios_developer2 = IosDeveloper.create!(name: 'Ethereum', identifier: '53453')
    @android_developer2 = AndroidDeveloper.create!(name: 'Bitcoin', identifier: '51234')

    @ios_app = IosApp.create!(app_identifier: 1, ios_developer_id: @ios_developer.id)
    @android_app = AndroidApp.create!(app_identifier: 1, android_developer_id: @android_developer.id)
   
  end

  def test_create_app_fields
    new_fields = [
      {label: 'MightySignal App ID', type: 'Text', length: 255},
      {label: 'MightySignal Key', type: 'Text', length: 255, externalId: true},
      {label: 'MightySignal Link', type: 'Url'},
      {label: 'Platform', type: 'Text', length: 255},
      {label: 'SDK Data', type: 'LongTextArea', length: 131072, visibleLines: 10},
      {label: 'Mobile Priority', type: 'Text', length: 255},
      {label: 'User Base', type: 'Text', length: 255},
      {label: 'Category', type: 'Text', length: 255},
      {label: 'Ad Spend', type: 'Checkbox', defaultValue: false},
      {label: 'Release Date', type: 'Date'},
      {label: 'Last Scanned Date', type: 'Date'},
      {label: 'Account Name', type: 'Lookup', fullName: "MightySignal_App__c.Account__c", referenceTo: 'Account', relationshipName: 'Apps'}
    ]

    new_fields.each do |field|
      @sf.expects(:add_custom_field).with('MightySignal_App__c', field)
    end

    @sf.create_app_fields
  end

  def test_create_sdk_fields
    new_fields = [
      {label: 'MightySignal SDK ID', type: 'Text', length: 255},
      {label: 'MightySignal Key', type: 'Text', length: 255, externalId: true},
      {label: 'MightySignal Link', type: 'Url'},
      {label: 'Website', type: 'Url'},
      {label: 'Platform', type: 'Text', length: 255},
      {label: 'Category', type: 'Picklist', picklist: {picklistValues: [{fullName: 'Analytics'}]}},
      {label: 'Category ID', type: 'Text', length: 255},
    ]

    new_fields.each do |field|
      @sf.expects(:add_custom_field).with('MightySignal_SDK__c', field)
    end

    @sf.create_sdk_fields
  end

  def test_create_app_ownership_fields
    new_fields = [
      {label: 'MightySignal Key', type: 'Text', length: 255, externalId: true},
      {label: 'Lead', type: 'Lookup', referenceTo: 'Lead', relationshipName: 'Lead'},
      {label: 'Account', type: 'Lookup', referenceTo: 'Account', relationshipName: 'Account'},
      {label: 'MightySignal App', type: 'MasterDetail', referenceTo: 'MightySignal_App__c', relationshipName: 'Lead_App'},
    ]

    new_fields.each do |field|
      @sf.expects(:add_custom_field).with('MightySignal_App_Ownership__c', field)
    end

    @sf.create_app_ownership_fields
  end

  def test_create_sdk_app_fields
    new_fields = [
      {label: 'MightySignal Key', type: 'Text', length: 255, externalId: true},
      {label: 'MightySignal SDK', type: 'MasterDetail', referenceTo: 'MightySignal_SDK__c', relationshipName: 'SDK'},
      {label: 'MightySignal App', type: 'MasterDetail', referenceTo: 'MightySignal_App__c', relationshipName: 'App'},
      {label: 'Installed', type: 'Date'},
      {label: 'Uninstalled', type: 'Date'},
    ]

    new_fields.each do |field|
      @sf.expects(:add_custom_field).with('MightySignal_SDK_App__c', field)
    end

    @sf.create_sdkapp_fields
  end

  def test_create_main_fields
    fields = { 
      "Publisher Name" => {length: 255, type: 'Text', label: "MightySignal Publisher Name"},
      "Website" => {length: 255, type: 'Text', label: "MightySignal Publisher Website"},
      "MightySignal iOS Publisher ID" => {type: 'Text', label: "MightySignal iOS Publisher ID", length: 255},
      "MightySignal iOS Link" => {type: 'Url', label: "MightySignal iOS Link"},
      "MightySignal iOS SDK Summary" => {length: 131072, type: 'LongTextArea', visibleLines: 10, label: "MightySignal iOS SDK Summary"},
      "MightySignal Android Publisher ID" => {length: 255, type: 'Text', label: "MightySignal Android Publisher ID"},
      "MightySignal Android Link" => {type: 'Url', label: "MightySignal Android Link"},
      "MightySignal Android SDK Summary" => {length: 131072, type: 'LongTextArea', visibleLines: 10, label: "MightySignal Android SDK Summary"},
      "MightySignal Last Synced" => {type: 'Date', label: "MightySignal Last Synced"}
    }
    fields.each do |field_key, field|
      @sf.expects(:add_custom_field).with('Account', field)
      @sf.expects(:add_custom_field).with('Lead', field)
    end

    @sf.create_main_fields
  end

  def test_that_domain_mapping_updates_salesforce
    DomainLinker.any_instance.stub(:domain_to_publisher) { [@ios_developer, @android_developer] }
    mock = Minitest::Mock.new
    mock.expect(:Id, '12345')
    mock.expect(:Id, '123456789')
    mock.expect(:Website, 'https://3comma.studio')
    mock.expect(:Website, 'https://3comma2.studio')
    mock.expect(:MightySignal_Android_Publisher_ID__c, nil)
    mock.expect(:MightySignal_iOS_Publisher_ID__c, nil)

    mock.expect(:MightySignal_Android_Publisher_ID__c, nil)
    mock.expect(:MightySignal_iOS_Publisher_ID__c, nil)

    @sf.client.expects(:query).with("select Id, Website, MightySignal_iOS_Publisher_ID__c, MightySignal_Android_Publisher_ID__c from Account where (MightySignal_iOS_Publisher_ID__c = null or MightySignal_Android_Publisher_ID__c = null) and Website != null").returns([mock])
    @sf.client.expects(:query).with("select Id, Website, MightySignal_iOS_Publisher_ID__c, MightySignal_Android_Publisher_ID__c from Lead where (MightySignal_iOS_Publisher_ID__c = null or MightySignal_Android_Publisher_ID__c = null) and Website != null and IsConverted = false").returns([mock])
    #assert_send([@sf.bulk_client, :update, 'Account', [{Id: '12345', MightySignal_iOS_Publisher_ID__c: @ios_developer.id}]])
    @sf.bulk_client.expects(:update).with('Account', [{Id: '12345', MightySignal_iOS_Publisher_ID__c: @ios_developer.id, MightySignal_Android_Publisher_ID__c: @android_developer.id}])
    @sf.bulk_client.expects(:update).with('Lead', [{Id: '123456789', MightySignal_iOS_Publisher_ID__c: @ios_developer.id, MightySignal_Android_Publisher_ID__c: @android_developer.id}])
    @sf.sync_domain_mapping
end

  def test_that_domain_mapping_date_works
    @sf.client.expects(:query).with("select Id, Website, MightySignal_iOS_Publisher_ID__c, MightySignal_Android_Publisher_ID__c from Account where (MightySignal_iOS_Publisher_ID__c = null or MightySignal_Android_Publisher_ID__c = null) and Website != null and CreatedDate > TODAY").returns([])
    @sf.client.expects(:query).with("select Id, Website, MightySignal_iOS_Publisher_ID__c, MightySignal_Android_Publisher_ID__c from Lead where (MightySignal_iOS_Publisher_ID__c = null or MightySignal_Android_Publisher_ID__c = null) and Website != null and IsConverted = false and CreatedDate > TODAY").returns([])
    @sf.sync_domain_mapping(date: 'TODAY')
  end

  def test_that_domain_mapping_custom_website_field_works
    @sf2.client.expects(:query).with("select Id, Website, MightySignal_iOS_Publisher_ID__c, MightySignal_Android_Publisher_ID__c from Account where (MightySignal_iOS_Publisher_ID__c = null or MightySignal_Android_Publisher_ID__c = null) and Website != null and CreatedDate > TODAY").returns([])
    @sf2.client.expects(:query).with("select Id, Website, MightySignal_iOS_Publisher_ID__c, MightySignal_Android_Publisher_ID__c, Email_Domain__c from Lead where (MightySignal_iOS_Publisher_ID__c = null or MightySignal_Android_Publisher_ID__c = null) and (Website != null or Email_Domain__c != null) and IsConverted = false and CreatedDate > TODAY").returns([])
    @sf2.sync_domain_mapping(date: 'TODAY')
  end

  def test_that_custom_website_field_works
    mock = Minitest::Mock.new
    mock2 = Minitest::Mock.new
    
    mock.expect(:Id, '12345')
    mock2.expect(:Id, '123456789')
    
    mock.expect(:Website, 'https://3comma.studio')
    
    mock2.expect(:[], 'https://test2.23', ['Email_Domain__c'])
    mock2.expect(:[], 'https://3comma2.studio', ['Website'])
    
    mock.expect(:MightySignal_Android_Publisher_ID__c, nil)
    mock.expect(:MightySignal_iOS_Publisher_ID__c, nil)

    mock2.expect(:MightySignal_Android_Publisher_ID__c, nil)
    mock2.expect(:MightySignal_iOS_Publisher_ID__c, nil)

    @sf2.client.expects(:query).with("select Id, Website, MightySignal_iOS_Publisher_ID__c, MightySignal_Android_Publisher_ID__c from Account where (MightySignal_iOS_Publisher_ID__c = null or MightySignal_Android_Publisher_ID__c = null) and Website != null and CreatedDate > TODAY").returns([mock])
    @sf2.client.expects(:query).with("select Id, Website, MightySignal_iOS_Publisher_ID__c, MightySignal_Android_Publisher_ID__c, Email_Domain__c from Lead where (MightySignal_iOS_Publisher_ID__c = null or MightySignal_Android_Publisher_ID__c = null) and (Website != null or Email_Domain__c != null) and IsConverted = false and CreatedDate > TODAY").returns([mock2])
    
    UrlHelper.expects(:url_with_domain_only).with('https://3comma.studio')
    UrlHelper.expects(:url_with_domain_only).with('https://test2.23')

    DomainLinker.any_instance.stub(:domain_to_publisher) { [] }

    @sf2.sync_domain_mapping(date: 'TODAY')
  end

  def test_that_sync_all_objects_queues_jobs
    mock1 = Minitest::Mock.new
    
    mock1.expect(:Id, '12345')
    mock1.expect(:Id, '123456789')
   
    # Account
    mock1.expect(:MightySignal_Android_Publisher_ID__c, @android_developer.id)
    mock1.expect(:MightySignal_iOS_Publisher_ID__c, @ios_developer2.id)
    mock1.expect(:MightySignal_Last_Synced__c, '2018-04-13')

    # Lead 
    mock1.expect(:MightySignal_Android_Publisher_ID__c, @android_developer2.id)
    mock1.expect(:MightySignal_iOS_Publisher_ID__c, @ios_developer.id)
    mock1.expect(:MightySignal_Last_Synced__c, '2018-04-13')

    mock2 = Minitest::Mock.new
    
    mock2.expect(:Id, '3453')
    mock2.expect(:Id, '57645645')

    # Account
    mock2.expect(:MightySignal_Android_Publisher_ID__c, @android_developer2.id)
    mock2.expect(:MightySignal_iOS_Publisher_ID__c, nil)
    mock2.expect(:MightySignal_Last_Synced__c, '2018-04-13')

    # Lead
    mock2.expect(:MightySignal_Android_Publisher_ID__c, @android_developer.id)
    mock2.expect(:MightySignal_iOS_Publisher_ID__c, nil)
    mock2.expect(:MightySignal_Last_Synced__c, '2018-04-13')


    @sf.client.stub(:query, [mock1, mock2]) do
      # Account
      SalesforceWorker.expects(:perform_async).with(:export_android_publisher, @android_developer.id, '12345', @user.id, 'Account') 
      SalesforceWorker.expects(:perform_async).with(:export_ios_publisher, @ios_developer2.id, '12345', @user.id, 'Account') 
      SalesforceWorker.expects(:perform_async).with(:export_android_publisher, @android_developer2.id, '3453', @user.id, 'Account')

      # Lead
      SalesforceWorker.expects(:perform_async).with(:export_ios_publisher, @ios_developer.id, '123456789', @user.id, 'Lead')
      SalesforceWorker.expects(:perform_async).with(:export_android_publisher, @android_developer2.id, '123456789', @user.id, 'Lead')
      SalesforceWorker.expects(:perform_async).with(:export_android_publisher, @android_developer.id, '57645645', @user.id, 'Lead') 

      account_publisher_array = [
        {publisher_id: @ios_developer2.id, platform: 'ios', export_id: '12345'},
        {publisher_id: @android_developer.id, platform: 'android', export_id: '12345'},
        {publisher_id: @android_developer2.id, platform: 'android', export_id: '3453'},
      ]

      lead_publisher_array = [
        {publisher_id: @ios_developer.id, platform: 'ios', export_id: '123456789'},
        {publisher_id: @android_developer2.id, platform: 'android', export_id: '123456789'},
        {publisher_id: @android_developer.id, platform: 'android', export_id: '57645645'},
      ]

      SalesforceWorker.expects(:perform_async).with(:export_publishers_apps, account_publisher_array, @user.id, 'Account')
      SalesforceWorker.expects(:perform_async).with(:export_publishers_apps, lead_publisher_array, @user.id, 'Lead')

      @sf.sync_all_objects     
    end
    
  end

  def test_that_default_mapping_maps_ios_fields
    assert_equal @sf.default_mapping(app: @ios_app), {
      "Website" => {"id"=>"Website", "name"=>"Website"},
      "MightySignal Last Synced" => {"id"=>"MightySignal_Last_Synced__c", "name"=>"New Field: MightySignal Last Synced"},
      "MightySignal iOS Publisher ID" => {"id"=>"MightySignal_iOS_Publisher_ID__c", "name"=>"New Field: MightySignal iOS Publisher ID"},
      "MightySignal iOS Link" => {"id"=>"MightySignal_iOS_Link__c", "name"=>"New Field: MightySignal iOS Link"},
      "Publisher Name" => {"id"=>"Name", "name"=>"Name"},
      "MightySignal iOS SDK Summary" => {"id"=>"MightySignal_iOS_SDK_Summary__c", "name"=>"New Field: MightySignal iOS SDK Summary"}
    }
  end

  def test_that_default_mapping_maps_android_fields
    assert_equal @sf.default_mapping(app: @android_app), {
      "Website" => {"id"=>"Website", "name"=>"Website"},
      "MightySignal Last Synced" => {"id"=>"MightySignal_Last_Synced__c", "name"=>"New Field: MightySignal Last Synced"},
      "MightySignal Android Publisher ID" => {"id"=>"MightySignal_Android_Publisher_ID__c", "name"=>"New Field: MightySignal Android Publisher ID"},
      "MightySignal Android Link" => {"id"=>"MightySignal_Android_Link__c", "name"=>"New Field: MightySignal Android Link"},
      "Publisher Name" => {"id"=>"Name", "name"=>"Name"},
      "MightySignal Android SDK Summary" => {"id"=>"MightySignal_Android_SDK_Summary__c", "name"=>"New Field: MightySignal Android SDK Summary"}
    }
  end

  def test_that_account_search_returns_correct_results
    mock = Minitest::Mock.new
    
    mock.expect(:Id, '12345')
    
    mock.expect(:Name, 'MightySignal')

    @sf.client.stubs(:query).returns([mock])

    assert_equal @sf.search('google'), [{id: '12345', name: 'MightySignal' }]

  end

  def test_that_lead_search_returns_correct_results
    @sf = SalesforceExportService.sf_for('MightySignal', 'Lead')

    mock = Minitest::Mock.new
    
    mock.expect(:Id, '12345')
    mock.expect(:Company, '3 Comma Studio')
    mock.expect(:FirstName, 'Matthew')
    mock.expect(:LastName, 'Hui')
    mock.expect(:Title, 'Founder')
    mock.expect(:Email, 'matt@3comma.studio')

    @sf.client.stubs(:query).returns([mock])

    assert_equal @sf.search('google'), [{
                                         name: "Matthew Hui - Founder\n3 Comma Studio",
                                         title: "Founder",
                                         id: '12345', 
                                         first_name: 'Matthew', 
                                         last_name: 'Hui', 
                                         email: 'matt@3comma.studio'
     }]

  end

  def test_that_export_new_publisher_exports_publisher_and_apps
    mock = Minitest::Mock.new
    mock.expect(:send!, nil)

    @sf.stubs(:developer_sdk_summary).returns("123")
    @sf.stubs(:object_has_field?).returns(true)
    SalesforceLogger.stubs(:new).returns(mock)
    @sf.stubs(:sdk_display).returns("123")

    new_object = {"MightySignal_iOS_Publisher_ID__c" => @ios_developer.id, 
                  "MightySignal_iOS_Link__c" => "https://mightysignal.com/app/app#/publisher/ios/#{@ios_developer.id}?utm_source=salesforce",
                  "MightySignal_iOS_SDK_Summary__c" => "123",
                  "Name" => "3 Comma Studio LLC",
                  "MightySignal_Last_Synced__c" => Date.today,
                  "AccountSource" => "MightySignal"}

    SalesforceWorker.expects(:perform_async)
    @sf.client.expects(:create!).with('Account', new_object)

    puts @sf.default_mapping(app: @ios_app)

    fields = { 
      "Publisher Name" => {data: '123', length: 255, type: 'Text', label: "MightySignal Publisher Name"},
      "MightySignal iOS Publisher ID" => {data: '123', type: 'Text', label: "MightySignal iOS Publisher ID", length: 255},
      "MightySignal iOS Link" => {data: '123', type: 'Url', label: "MightySignal iOS Link"},
      "MightySignal iOS SDK Summary" => {data: '123', length: 131072, type: 'LongTextArea', visibleLines: 10, label: "MightySignal iOS SDK Summary"},
      "MightySignal Last Synced" => {:type => "Date", :label => "MightySignal Last Synced"}
    }

    fields.each do |field_key, field|
      @sf.expects(:add_custom_field).with('Account', field.except(:data))
    end

    @sf.export(app: @ios_app)
  end

  def test_that_should_skip_fields_works
    map = {"id" => "Name","name" => "Name"}
    data = {Name: {length: 255, type: 'Text', label: "MightySignal Publisher Name", data: "Test Account"}}.with_indifferent_access

    assert_equal @sf.should_skip_field?('Name', map, data, nil), false
  end

  def test_that_blacklisting_sdk_tags_works
    @sf.instance_variable_set(:@upsert_records, {MightySignal_App__c: [{Platform__c: 'ios', MightySignal_App_ID__c: @ios_app.id}]}.with_indifferent_access)
      
    Account.any_instance.stub(:blacklisted_sdk_tags) {
      [1]
    }

    @sf.bulk_client.stubs(:upsert).returns({
      'batches' => [
        {'response' => [{'id' => '123'}]}
      ]
    })

    @sf.expects(:import_sdk).with(
      platform: 'ios',
      sdk: {
        "id"=>92, 
        "name"=>"Amplitude-iOS", 
        "website"=>"https://amplitude.com", 
        "favicon"=>"https://www.google.com/s2/favicons?domain=amplitude.com", 
        "first_seen_date"=>"2015-12-01T18:14:43.000-08:00", 
        "last_seen_date"=>"2018-01-25T13:04:23.000-08:00"
      },
      category: {
        "name"=>"Analytics", 
        "id"=>1
      } 
    ).never
    @sf.expects(:import_sdk).with(
      platform: 'ios',
      sdk: {
        "id"=>1648,
        "name"=>"KVOController",
        "website"=>"https://github.com/facebook/KVOController",
        "favicon"=>"https://www.google.com/s2/favicons?domain=code.facebook.com",
        "first_seen_date"=>"2015-12-01T18:14:43.000-08:00",
        "last_seen_date"=>"2017-02-02T15:05:56.000-08:00",
      },
      category: {
        "name"=>"Infrastructure", 
        "id"=>5
      } 
    )

    IosApp.any_instance.stub(:tagged_sdk_response) {
      {
        "installed_sdks" => [{
          "name"=>"Analytics",
          "id"=>1, 
          "sdks"=>[{
            "id"=>92, 
            "name"=>"Amplitude-iOS", 
            "website"=>"https://amplitude.com", 
            "favicon"=>"https://www.google.com/s2/favicons?domain=amplitude.com", 
            "first_seen_date"=>"2015-12-01T18:14:43.000-08:00", 
            "last_seen_date"=>"2018-01-25T13:04:23.000-08:00"
          }]
        }],
        "uninstalled_sdks" => [{
          "name"=>"Infrastructure", 
          "id"=>5, 
          "sdks"=>[{
            "id"=>1648,
            "name"=>"KVOController",
            "website"=>"https://github.com/facebook/KVOController",
            "favicon"=>"https://www.google.com/s2/favicons?domain=code.facebook.com",
            "first_seen_date"=>"2015-12-01T18:14:43.000-08:00",
            "last_seen_date"=>"2017-02-02T15:05:56.000-08:00",
          }]
        }]
      }.with_indifferent_access
    }

    @sf.run_app_imports
  end

  
end
