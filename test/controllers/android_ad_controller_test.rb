require 'test_helper'
require 'action_controller'

class AndroidAdControllerTest < ActionController::TestCase
  def setup
    account = Account.create(name: 'MightySignal')
    user = User.create(is_admin: true, email: 'matt@mightysignal.com', account_id: account.id, password: '12345')
    @source_app = AndroidApp.create(:app_identifier => 'com.facebook.katana')
    @advertised_app = AndroidApp.create(:app_identifier => 'com.mightysignal.security')
    @token = user.generate_auth_token()
  end

  def test_create_ad_impression
    @request.headers['Authorization'] = @token
    verbatum_params = {
      ad_type: 'mobile_app',
      android_device_sn: '123device',
      ad_id: 's3://somekey',
      google_account: 'm@gmail.com',
      facebook_account: 'fb_acc',
      ad_text: 'Def install this app',
      target_location: 'United States',
      target_max_age: 24,
      target_min_age: 18,
      target_similar_to_existing_users: true,
      target_gender: 'male',
      target_education: 'BA',
      target_existing_users: true,
      target_language: 'English (UK)',
      target_relationship_status: 'single',
      target_proximity_to_business: true,
    }
    post(:create, {
      target_interests: 'reading|violin|coffee',
      source_app_identifier: 'com.facebook.katana',
      advertised_app_identifier: 'com.mightysignal.security',
      }.merge(verbatum_params)
    )

    ad = AndroidAd.last

    verbatum_params.each do |k,v|
      assert_equal v, ad.send(k.to_sym), k
    end

    assert_equal 'reading|violin|coffee'.split('|'), ad.target_interests
    assert_equal @source_app, ad.source_app
    assert_equal @advertised_app, ad.advertised_app

  end

  def test_minimal_create_ad_impression
    @request.headers['Authorization'] = @token
    verbatum_params = {
      ad_type: 'mobile_app',
    }
    post(:create, {
      source_app_identifier: 'com.facebook.katana',
      advertised_app_identifier: 'com.mightysignal.security',
      }.merge(verbatum_params)
    )

    ad = AndroidAd.last

    assert_equal ad.ad_type, 'mobile_app'
    assert_equal @source_app, ad.source_app
    assert_equal @advertised_app, ad.advertised_app

  end


end
