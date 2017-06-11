require 'test_helper'

class AppStoreDevelopersTestWorkerTest < ActiveSupport::TestCase

  def setup
    @first_app = IosApp.create!(app_identifier: 1)
    @second_app = IosApp.create!(app_identifier: 2)
    @developer_identifier = 123
    @seller_name = 'new name'

    [@first_app.id, @second_app.id].each do |ios_app_id|
      IosAppCurrentSnapshot.create!(
        ios_app_id: ios_app_id,
        developer_app_store_identifier: @developer_identifier,
        seller_name: @seller_name,
        latest: true
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
    assert_nil @second_app.ios_developer_id
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

  test 'Does not add duplicate entries into ios_developers_website table' do
    developer = IosDeveloper.create!(name: 'old name', identifier: @developer_identifier)
    # Need to create another IosAppCurrentSnapshot entry to add a seller_url
    IosAppCurrentSnapshot.where(ios_app_id: @first_app.id).update_all(latest: false)
    ios_app = IosAppCurrentSnapshot.create!(developer_app_store_identifier: @developer_identifier, ios_app_id: @first_app.id, seller_name: @seller_name, seller_url: "https://seller.com", latest: true)
    website = Website.create!(
      url: 'https://seller.com',
      match_string: 'https://seller.com',
      domain: 'https://seller.com'
    )
    IosDevelopersWebsite.create!(ios_developer_id: developer.id, website_id: website.id, is_valid: true)
    AppStoreDevelopersWorker.new.create_by_ios_app_id(@first_app.id)

    assert_equal 1, IosDevelopersWebsite.where(ios_developer_id: developer.id).length
    assert_equal 1, developer.websites.length
    assert developer.websites.pluck(:url).include? 'https://seller.com'
  end

  test 'Creates website and ios_developers_website entries if new website' do
    developer = IosDeveloper.create!(name: 'old name', identifier: @developer_identifier)
    IosAppCurrentSnapshot.where(ios_app_id: @first_app.id).update_all(latest: false)
    IosAppCurrentSnapshot.where(ios_app_id: @second_app.id).update_all(latest: false)
    IosAppCurrentSnapshot.create!(developer_app_store_identifier: @developer_identifier, ios_app_id: @first_app.id, seller_name: @seller_name, seller_url: "https://seller.com", latest: true)
    IosAppCurrentSnapshot.create!(developer_app_store_identifier: @developer_identifier, ios_app_id: @second_app.id, seller_name: @seller_name, seller_url: "https://seller2.com", latest: true)
    website = Website.create!(
      url: 'https://seller.com',
      match_string: 'https://seller.com',
      domain: 'https://seller.com'
    )
    IosDevelopersWebsite.create!(ios_developer_id: developer.id, website_id: website.id, is_valid: true)
    AppStoreDevelopersWorker.new.create_by_ios_app_id(@first_app.id)

    assert_equal 2, IosDevelopersWebsite.where(ios_developer_id: developer.id).length
    assert_equal 2, developer.websites.length
    assert_equal 1, Website.where(url: 'https://seller2.com').to_a.length
    assert developer.websites.pluck(:url).include? 'https://seller2.com'
    assert developer.websites.pluck(:url).include? 'https://seller.com'
  end

  test 'Creates developer and ios_developers_website entries if new developer' do
    IosAppCurrentSnapshot.where(ios_app_id: @first_app.id).update_all(latest: false)
    IosAppCurrentSnapshot.where(ios_app_id: @second_app.id).update_all(latest: false)
    IosAppCurrentSnapshot.create!(developer_app_store_identifier: @developer_identifier, ios_app_id: @first_app.id, seller_name: @seller_name, seller_url: "https://seller.com", latest: true)
    IosAppCurrentSnapshot.create!(developer_app_store_identifier: @developer_identifier, ios_app_id: @second_app.id, seller_name: @seller_name, seller_url: "https://seller2.com", latest: true)
    website = Website.create!(
      url: 'https://seller.com',
      match_string: 'https://seller.com',
      domain: 'https://seller.com'
    )
    AppStoreDevelopersWorker.new.create_by_ios_app_id(@first_app.id)
    developer = IosDeveloper.where(identifier: @developer_identifier).first

    assert_not_nil developer
    assert_equal 2, IosDevelopersWebsite.where(ios_developer_id: developer.id).length
    assert_equal 2, developer.websites.length
    assert developer.websites.pluck(:url).include? 'https://seller2.com'
    assert developer.websites.pluck(:url).include? 'https://seller.com'
  end

  test 'Updates apps developer id attribute' do
    IosAppCurrentSnapshot.where(ios_app_id: @first_app.id).update_all(latest: false)
    IosAppCurrentSnapshot.where(ios_app_id: @second_app.id).update_all(latest: false)
    IosAppCurrentSnapshot.create!(developer_app_store_identifier: @developer_identifier, ios_app_id: @first_app.id, seller_name: @seller_name, seller_url: "https://seller.com", latest: true)
    IosAppCurrentSnapshot.create!(developer_app_store_identifier: @developer_identifier, ios_app_id: @second_app.id, seller_name: @seller_name, seller_url: "https://seller2.com", latest: true)
    
    AppStoreDevelopersWorker.new.create_by_ios_app_id(@first_app.id)
    developer = IosDeveloper.where(identifier: @developer_identifier).first

    assert_not_nil developer
    assert_equal developer.id, IosApp.find(@first_app.id).ios_developer_id
    assert_equal developer.id, IosApp.find(@second_app.id).ios_developer_id
  end

end
