require 'test_helper'

class AppStoreDevelopersTestWorkerTest < ActiveSupport::TestCase

  def setup
    @first_app = IosApp.create!(app_identifier: 1)
    @second_app = IosApp.create!(app_identifier: 2)
    @developer_identifier = 123
    @seller_name = 'new name'

    [@first_app.id, @second_app.id].each do |ios_app_id|
      IosAppCurrentSnapshotBackup.create!(
        ios_app_id: ios_app_id,
        developer_app_store_identifier: @developer_identifier,
        seller_name: @seller_name
      )
    end
  end

  test 'create by ios app id populates both apps' do
    AppStoreDevelopersWorker.new.create_by_ios_app_id(@first_app.id)

    @first_app.reload
    @second_app.reload
    assert_equal @developer_identifier, @first_app.ios_developer.identifier
    assert_equal @first_app.ios_developer_id, @second_app.ios_developer_id
  end

  test 'quits developer creation early if ios_developer_id is defined' do
    @first_app.update!(ios_developer_id: 123123)

    AppStoreDevelopersWorker.new.create_by_ios_app_id(@first_app.id)
    @second_app.reload

    assert_equal 123123, @first_app.ios_developer_id
    assert_equal nil, @second_app.ios_developer_id
  end

  test 'does not quit developer creation early if specified' do
    @first_app.update!(ios_developer_id: 123123)

    AppStoreDevelopersWorker.new.create_by_ios_app_id(@first_app.id, ensure_required: false)
    @first_app.reload
    @second_app.reload

    assert @first_app.ios_developer
    assert_equal @developer_identifier, @first_app.ios_developer.identifier
    assert_equal @first_app.ios_developer_id, @second_app.ios_developer_id
  end

  test 'Updates developer name with newest information' do
    developer = IosDeveloper.create!(name: 'old name', identifier: @developer_identifier)
    AppStoreDevelopersWorker.new.create_by_ios_app_id(@first_app.id)

    assert_equal @seller_name, developer.reload.name
  end

end
