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

    @user = User.create!(account_id: @account.id, email: 'matt@mightysignal.com', password: '12345')
    @sf = SalesforceExportService.sf_for('MightySignal')

    @ios_developer = IosDeveloper.create!(name: '3 Comma Studio LLC', identifier: '12345')
    @android_developer = AndroidDeveloper.create!(name: '3 Comma Studio LLC', identifier: '12345')

    @ios_developer2 = IosDeveloper.create!(name: 'Ethereum', identifier: '53453')
    @android_developer2 = AndroidDeveloper.create!(name: 'Bitcoin', identifier: '51234')

    @ios_app = IosApp.create!(app_identifier: 1, ios_developer_id: @ios_developer.id)
    @android_app = AndroidApp.create!(app_identifier: 1, android_developer_id: @android_developer.id)
   
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

    @sf.client.stub(:query, [mock]) do
      #assert_send([@sf.bulk_client, :update, 'Account', [{Id: '12345', MightySignal_iOS_Publisher_ID__c: @ios_developer.id}]])
      @sf.bulk_client.expects(:update).with('Account', [{Id: '12345', MightySignal_iOS_Publisher_ID__c: @ios_developer.id, MightySignal_Android_Publisher_ID__c: @android_developer.id}])
      @sf.bulk_client.expects(:update).with('Lead', [{Id: '123456789', MightySignal_iOS_Publisher_ID__c: @ios_developer.id, MightySignal_Android_Publisher_ID__c: @android_developer.id}])
      @sf.sync_domain_mapping
    end
  end

  def test_that_sync_all_objects_queues_jobs
    mock1 = Minitest::Mock.new
    
    mock1.expect(:Id, '12345')
    mock1.expect(:Id, '123456789')
   
    # Account
    mock1.expect(:MightySignal_Android_Publisher_ID__c, @android_developer.id)
    mock1.expect(:MightySignal_iOS_Publisher_ID__c, @ios_developer2.id)

    # Lead 
    mock1.expect(:MightySignal_Android_Publisher_ID__c, @android_developer2.id)
    mock1.expect(:MightySignal_iOS_Publisher_ID__c, @ios_developer.id)

    mock2 = Minitest::Mock.new
    
    mock2.expect(:Id, '3453')
    mock2.expect(:Id, '57645645')

    # Account
    mock2.expect(:MightySignal_Android_Publisher_ID__c, @android_developer2.id)
    mock2.expect(:MightySignal_iOS_Publisher_ID__c, nil)

    # Lead
    mock2.expect(:MightySignal_Android_Publisher_ID__c, @android_developer.id)
    mock2.expect(:MightySignal_iOS_Publisher_ID__c, nil)


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

      SalesforceWorker.expects(:perform_async).with(:export_publishers, account_publisher_array, @user.id, 'Account')
      SalesforceWorker.expects(:perform_async).with(:export_publishers, lead_publisher_array, @user.id, 'Lead')

      @sf.sync_all_objects     
    end
    
  end

  def test_that_default_mapping_maps_ios_fields
    assert_equal @sf.default_mapping(app: @ios_app), {
      "Website" => {"id"=>"Website", "name"=>"Website"},
      "MightySignal iOS Publisher ID" => {"id"=>"MightySignal_iOS_Publisher_ID__c", "name"=>"New Field: MightySignal iOS Publisher ID"},
      "MightySignal iOS Link" => {"id"=>"MightySignal_iOS_Link__c", "name"=>"New Field: MightySignal iOS Link"},
      "Publisher Name" => {"id"=>"Name", "name"=>"Name"},
      "MightySignal iOS SDK Summary" => {"id"=>"MightySignal_iOS_SDK_Summary__c", "name"=>"New Field: MightySignal iOS SDK Summary"}
    }
  end

  def test_that_default_mapping_maps_android_fields
    assert_equal @sf.default_mapping(app: @android_app), {
      "Website" => {"id"=>"Website", "name"=>"Website"},
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

    @sf.stubs(:developer_sdk_summary).returns("")
    @sf.stubs(:object_has_field?).returns(true)
    SalesforceLogger.stubs(:new).returns(mock)
    @sf.stubs(:sdk_display).returns("")

    new_object = {"MightySignal_iOS_Publisher_ID__c" => @ios_developer.id, 
                  "MightySignal_iOS_Link__c" => "https://mightysignal.com/app/app#/publisher/ios/#{@ios_developer.id}?utm_source=salesforce",
                  "Name" => "3 Comma Studio LLC",
                  "AccountSource" => "MightySignal"}

    SalesforceWorker.expects(:perform_async)
    @sf.client.expects(:create!).with('Account', new_object)
    @sf.export(app: @ios_app)
  end

  def test_that_should_skip_fields_works
    map = {"id" => "Name","name" => "Name"}
    data = {Name: {length: 255, type: 'Text', label: "MightySignal Publisher Name", data: "Test Account"}}.with_indifferent_access

    assert_equal @sf.should_skip_field?('Name', map, data, nil), false
  end





  
end
