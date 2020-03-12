require 'test_helper'
require 'mocha/mini_test'

class SalesforceWorkerTest < ActiveSupport::TestCase

  def setup 
    salesforce_token = '00Dg0000006Hs29!AQ8AQDGkEwFZmwsbQ1G5sblHHp7yc6FSm3cH_Lp9tigyppstUU0nn.eVuUEr3DPp9G7oelNwBpMOcI7psvblo9e6ywj8Exx9'
    salesforce_refresh_token = "5Aep861O1Hc8GWyS4GrLjaJC8MMBmBs3SAIcz1HrtONd5ddTbJ6lLa_DP09Qw2SVoEH7_csbZPDq6COfQhE9sxH"
    @account = Account.create!(
      name: 'MightySignal', 
      salesforce_token: salesforce_token, 
      salesforce_refresh_token: salesforce_refresh_token,
      salesforce_uid: '0050a00000ForTZAAZ',
      salesforce_settings: {"is_sandbox"=>true, 'sync_domain_mapping' => '1w'},
      salesforce_instance_url: 'https://cs17.salesforce.com',
      salesforce_syncing: true,
      salesforce_status: :ready
    ) 

    @account2 = Account.create!(
      name: '3 Comma', 
      salesforce_token: salesforce_token, 
      salesforce_refresh_token: salesforce_refresh_token,
      salesforce_uid: '0050a00000ForTZAAZ',
      salesforce_settings: {"is_sandbox"=>true},
      salesforce_instance_url: 'https://cs17.salesforce.com',
    ) 

    @account3 = Account.create!(
      name: 'Coinbuddy', 
      salesforce_token: salesforce_token, 
      salesforce_refresh_token: salesforce_refresh_token,
      salesforce_uid: '0050a00000ForTZAAZ',
      salesforce_settings: {"is_sandbox"=>true, 'sync_domain_mapping' => '5m'},
      salesforce_instance_url: 'https://cs17.salesforce.com',
      salesforce_syncing: true,
      salesforce_status: :ready
    ) 

    @user = User.create!(account_id: @account.id, email: 'matt@mightysignal.com', password: '12345')
    @user2 = User.create!(account_id: @account2.id, email: 'bob@mightysignal.com', password: '12345')
    @user3 = User.create!(account_id: @account3.id, email: 'jesuschrist@mightysignal.com', password: '12345')
    
    @sf = SalesforceExportService.sf_for('MightySignal')
    @sf2 = SalesforceExportService.sf_for('3 Comma')
    @sf3 = SalesforceExportService.sf_for('Coinbuddy')

    @ios_developer = IosDeveloper.create!(name: '3 Comma Studio LLC', identifier: '12345')
    @android_developer = AndroidDeveloper.create!(name: '3 Comma Studio LLC', identifier: '12345')

    @ios_developer2 = IosDeveloper.create!(name: 'Ethereum', identifier: '53453')
    @android_developer2 = AndroidDeveloper.create!(name: 'Bitcoin', identifier: '51234')

    @ios_app = IosApp.create!(app_identifier: 1, ios_developer_id: @ios_developer.id)
    @android_app = AndroidApp.create!(app_identifier: 1, android_developer_id: @android_developer.id)

    @formatted_imports = [
      {'publisher_id' => @ios_developer2.id, 'platform' => 'ios', 'export_id' => '12345', 'publisher' => @ios_developer2},
      {'publisher_id' => @android_developer.id, 'platform' => 'android', 'export_id' => '12345', 'publisher' => @android_developer},
      {'publisher_id' => @android_developer2.id, 'platform' => 'android', 'export_id' => '3453', 'publisher' => @android_developer2},
    ]

    @raw_imports = [
      {'publisher_id' => @ios_developer2.id, 'platform' => 'ios', 'export_id' => '12345'},
      {'publisher_id' => @android_developer.id, 'platform' => 'android', 'export_id' => '12345'},
      {'publisher_id' => @android_developer2.id, 'platform' => 'android', 'export_id' => '3453'},
    ]
   
  end

  def test_that_sync_all_accounts_runs_sync
    SalesforceExportService.stubs(:new).with(user: @user).returns(@sf)
    SalesforceExportService.stubs(:new).with(user: @user2).returns(@sf2)
    SalesforceExportService.stubs(:new).with(user: @user3).returns(@sf3)

    SalesforceWorker.expects(:perform_async).with(:sync_account, @user.account.id)
    SalesforceWorker.expects(:perform_async).with(:sync_account, @user2.account.id).never
    SalesforceWorker.expects(:perform_async).with(:sync_account, @user3.account.id)

    SalesforceWorker.new.perform(:sync_all_accounts)
  end

  def test_that_sync_account_runs_sync
    SalesforceExportService.stubs(:new).with(user: @user).returns(@sf)
    @sf.expects(:sync_all_objects)
    SalesforceWorker.new.perform(:sync_account, @user.account.id)
  end

  def test_that_sync_all_domain_mapping_runs_sync
    SalesforceWorker.expects(:perform_async).with(:sync_domain_mapping, @account.id, nil, :salesforce_syncer)
    SalesforceWorker.expects(:perform_async).with(:sync_domain_mapping, @account2.id).never

    SalesforceWorker.new.perform(:sync_domain_mapping_all_accounts)
  end

  def test_that_sync_all_domain_mapping_runs_sync_with_frequency
    SalesforceWorker.expects(:perform_async).with(:sync_domain_mapping, @account.id).never
    SalesforceWorker.expects(:perform_async).with(:sync_domain_mapping, @account3.id, 'YESTERDAY', :salesforce_syncer)
    SalesforceWorker.expects(:perform_async).with(:sync_domain_mapping, @account2.id).never

    SalesforceWorker.new.perform(:sync_domain_mapping_all_accounts, frequency: 
      '5m')
  end

  def test_that_sync_domain_mapping_runs_sync
    SalesforceExportService.stubs(:new).with(user: @user).returns(@sf)
    @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 1000,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 1000,
        'Max' => 1100
      }
    })

    @sf.expects(:sync_domain_mapping)

    SalesforceWorker.new.perform(:sync_domain_mapping, @account.id)
  end

  def test_that_sync_domain_mapping_runs_sync_with_date
    SalesforceExportService.stubs(:new).with(user: @user).returns(@sf)
    @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 1000,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 1000,
        'Max' => 1100
      }
    })

    @sf.expects(:sync_domain_mapping).with(date: 'TODAY', queue: :salesforce_syncer)

    SalesforceWorker.new.perform(:sync_domain_mapping, @account.id, 'TODAY')
  end

  def test_that_sync_domain_mapping_runs_sync_rate_limit
    SalesforceExportService.stubs(:new).with(user: @user).returns(@sf)
    @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      }
    })

    @sf.expects(:sync_domain_mapping).never
    SalesforceWorker.expects(:perform_in).with(6.hours, :sync_domain_mapping, @account.id, nil, :salesforce_syncer)

    SalesforceWorker.new.perform(:sync_domain_mapping, @account.id)
  end

  def test_that_export_ios_publisher_runs_export
    SalesforceExportService.stubs(:new).with(user: @user, model_name: 'Account').returns(@sf)
    @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 800,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 800,
        'Max' => 1100
      }
    })

    @sf.expects(:export).with(publisher: @ios_developer, object_id: '123123123', export_apps: false)

    SalesforceWorker.new.perform(:export_ios_publisher, @ios_developer.id, '123123123', @user.id, 'Account')
  end

  def test_that_export_ios_publisher_runs_export_rate_limit
    SalesforceExportService.stubs(:new).with(user: @user, model_name: 'Account').returns(@sf)
    @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      }
    })

    @sf.expects(:export).with(publisher: @ios_developer, object_id: '123123123', export_apps: false).never
    SalesforceWorker.expects(:perform_in).with(6.hours, :export_ios_publisher, @ios_developer.id, '123123123', @user.id, 'Account')

    SalesforceWorker.new.perform(:export_ios_publisher, @ios_developer.id, '123123123', @user.id, 'Account')
  end

  def test_that_export_android_publisher_runs_export
    SalesforceExportService.stubs(:new).with(user: @user, model_name: 'Account').returns(@sf)
    @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 800,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 800,
        'Max' => 1100
      }
    })

    @sf.expects(:export).with(publisher: @android_developer, object_id: '123123123', export_apps: false)

    SalesforceWorker.new.perform(:export_android_publisher, @android_developer.id, '123123123', @user.id, 'Account')
  end

  def test_that_export_android_publisher_runs_export_rate_limit
    SalesforceExportService.stubs(:new).with(user: @user, model_name: 'Account').returns(@sf)
    @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      }
    })

    @sf.expects(:export).with(publisher: @android_developer, object_id: '123123123', export_apps: false).never
    SalesforceWorker.expects(:perform_in).with(6.hours, :export_android_publisher, @android_developer.id, '123123123', @user.id, 'Account')

    SalesforceWorker.new.perform(:export_android_publisher, @android_developer.id, '123123123', @user.id, 'Account')
  end

  def test_that_export_publishers_runs_export
    SalesforceExportService.stubs(:new).with(user: @user, model_name: 'Account').returns(@sf)
    
    @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 700,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 700,
        'Max' => 1100
      }
    })

    @sf.expects(:import_publishers_apps).with(@formatted_imports)

    SalesforceWorker.new.perform(:export_publishers_apps, @raw_imports, @user.id, 'Account')
  end

  def test_that_export_publishers_runs_export_rate_limit

    SalesforceExportService.stubs(:new).with(user: @user, model_name: 'Account').returns(@sf)
    @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      }
    })

    SalesforceWorker.expects(:perform_in).with(6.hours, :export_publishers_apps, @raw_imports, @user.id, 'Account')

  
    SalesforceWorker.new.perform(:export_publishers_apps, @raw_imports, @user.id, 'Account')
  end

  def test_that_export_ios_apps_runs_export
    SalesforceExportService.stubs(:new).with(user: @user, model_name: 'Account').returns(@sf)
    
     @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 700,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 700,
        'Max' => 1100
      }
    })

    @sf.expects(:import_publishers_apps).with([{publisher: @ios_developer, export_id: '12345'}])

    SalesforceWorker.new.perform(:export_ios_apps, @ios_app.id, '12345', @user.id, 'Account')
  end

  def test_that_export_ios_apps_runs_export_rate_limit
    SalesforceExportService.stubs(:new).with(user: @user, model_name: 'Account').returns(@sf)
    
     @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      }
    })

    @sf.expects(:import_publishers_apps).with([{publisher: @ios_developer, export_id: '12345'}]).never
    SalesforceWorker.expects(:perform_in).with(6.hours, :export_ios_apps, @ios_app.id, '12345', @user.id, 'Account')

    SalesforceWorker.new.perform(:export_ios_apps, @ios_app.id, '12345', @user.id, 'Account')
  end

  def test_that_export_android_apps_runs_export
    SalesforceExportService.stubs(:new).with(user: @user, model_name: 'Account').returns(@sf)
    
     @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 700,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 700,
        'Max' => 1100
      }
    })

    @sf.expects(:import_publishers_apps).with([{publisher: @android_developer, export_id: '12345'}])

    SalesforceWorker.new.perform(:export_android_apps, @android_app.id, '12345', @user.id, 'Account')
  end

  def test_that_export_android_apps_runs_export_rate_limit
    SalesforceExportService.stubs(:new).with(user: @user, model_name: 'Account').returns(@sf)
    
     @sf.client.stubs(:limits).returns({
      'DailyApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      },
      'DailyBulkApiRequests' => {
        'Remaining' => 100,
        'Max' => 1100
      }
    })

    @sf.expects(:import_publishers_apps).with([{publisher: @android_developer, export_id: '12345'}]).never
    SalesforceWorker.expects(:perform_in).with(6.hours, :export_android_apps, @android_app.id, '12345', @user.id, 'Account')

    SalesforceWorker.new.perform(:export_android_apps, @android_app.id, '12345', @user.id, 'Account')
  end


  
end
