class FeaturePermissionTest < ActiveSupport::TestCase

  def setup
    @account = Account.create!(:name => "Test Account")
    @base_feature_permission_flag = FeaturePermissionFlag.create!(:name => "Explore", :enabled => true)
    @not_base_feature_permission_flag = FeaturePermissionFlag.create!(:name => "Ad Intel v2", :enabled => false)

    @account_2 = Account.create!(:name => "Test Account 2", :feature_permissions => { "MY_INITIAL_FEATURE" => true })
  end

  test 'Available features' do
    assert_equal({ "MY_INITIAL_FEATURE" => true, "Explore" => true, "Ad Intel v2" => false }, @account_2.feature_flag_map)
  end

  test 'Enable feature permissions' do
    @account.enable_feature!("MY_COOL_NEW_FEATURE")
    saved_account = Account.find(@account.id)

    assert_equal({ "MY_COOL_NEW_FEATURE" => true }, saved_account.feature_permissions)
    assert_equal({ "MY_COOL_NEW_FEATURE" => true, "Explore" => true, "Ad Intel v2" => false }, saved_account.feature_flag_map)
    assert saved_account.can_access_feature?("MY_COOL_NEW_FEATURE")
  end

  test 'Enable global feature' do
    @account.enable_feature!("Ad Intel v2")
    saved_account = Account.find(@account.id)

    assert_equal({ "Explore" => true, "Ad Intel v2" => true }, saved_account.feature_flag_map)
  end

  test 'Disable feature permissions' do
    @account_2.disable_feature!("MY_INITIAL_FEATURE")
    saved_account = Account.find(@account_2.id)

    assert_equal({ "MY_INITIAL_FEATURE" => false }, saved_account.feature_permissions)
    assert_equal({ "MY_INITIAL_FEATURE" => false, "Explore" => true, "Ad Intel v2" => false }, saved_account.feature_flag_map)
    assert !saved_account.can_access_feature?("MY_COOL_NEW_FEATURE")
  end

  test 'Disable global feature' do
    @account_2.disable_feature!("Explore")
    saved_account = Account.find(@account_2.id)

    assert_equal({ "MY_INITIAL_FEATURE" => true, "Explore" => false, "Ad Intel v2" => false }, saved_account.feature_flag_map)
  end

  test 'Determines can access feature' do
    assert @account.can_access_feature?("Explore")
    assert !@account.can_access_feature?("Ad Intel v2")
    assert @account_2.can_access_feature?("Explore")
    assert !@account_2.can_access_feature?("Ad Intel v2")
    assert @account_2.can_access_feature?("MY_INITIAL_FEATURE")
  end

  test 'Bulk enable' do
    Account.bulk_enable_feature!("FEATURE_FOR_ALL", ids: [ @account.id, @account_2.id ])

    assert Account.find(@account.id).feature_permissions["FEATURE_FOR_ALL"]
    assert Account.find(@account_2.id).feature_permissions["FEATURE_FOR_ALL"]
  end

  test 'Bulk disable' do
    Account.bulk_enable_feature!("FEATURE_FOR_ALL_1", ids: [ @account.id, @account_2.id ])
    Account.bulk_enable_feature!("FEATURE_FOR_ALL_2", ids: [ @account.id, @account_2.id ])

    assert Account.find(@account.id).feature_permissions["FEATURE_FOR_ALL_1"]
    assert Account.find(@account_2.id).feature_permissions["FEATURE_FOR_ALL_2"]
    assert Account.find(@account.id).feature_permissions["FEATURE_FOR_ALL_1"]
    assert Account.find(@account_2.id).feature_permissions["FEATURE_FOR_ALL_2"]

    Account.bulk_disable_feature!("FEATURE_FOR_ALL_2", ids: [ @account.id, @account_2.id ])

    assert Account.find(@account.id).feature_permissions["FEATURE_FOR_ALL_1"]
    assert Account.find(@account_2.id).feature_permissions["FEATURE_FOR_ALL_1"]
    assert !Account.find(@account.id).feature_permissions["FEATURE_FOR_ALL_2"]
    assert !Account.find(@account_2.id).feature_permissions["FEATURE_FOR_ALL_2"]
  end

  test 'Disable for all' do
    Account.bulk_enable_feature!("FEATURE_FOR_ALL_1", ids: [ @account.id, @account_2.id ])
    Account.bulk_enable_feature!("FEATURE_FOR_ALL_2", ids: [ @account.id, @account_2.id ])

    assert Account.find(@account.id).feature_permissions["FEATURE_FOR_ALL_1"]
    assert Account.find(@account_2.id).feature_permissions["FEATURE_FOR_ALL_2"]
    assert Account.find(@account.id).feature_permissions["FEATURE_FOR_ALL_1"]
    assert Account.find(@account_2.id).feature_permissions["FEATURE_FOR_ALL_2"]

    Account.disable_feature_for_all!("FEATURE_FOR_ALL_2")

    assert Account.find(@account.id).feature_permissions["FEATURE_FOR_ALL_1"]
    assert !Account.find(@account_2.id).feature_permissions["FEATURE_FOR_ALL_2"]
    assert Account.find(@account.id).feature_permissions["FEATURE_FOR_ALL_1"]
    assert !Account.find(@account_2.id).feature_permissions["FEATURE_FOR_ALL_2"]
  end

  test 'All ids with feature enabled' do
    initial_feature_ids = Account.all_ids_with_feature_enabled("MY_INITIAL_FEATURE")
    assert_equal [ @account_2.id ], initial_feature_ids

    base_feature_ids = Account.all_ids_with_feature_enabled("Explore")
    assert_equal Account.all.pluck(:id).sort, base_feature_ids.sort
  end

end