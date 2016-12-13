require 'test_helper'

class WebsiteFeatureTest < ActiveSupport::TestCase
  test "website feature creation" do
    account = Account.create(name: 'MightySignal')
    user = User.create(email: 'matty@mightysignal.com', account_id: account.id, password: '12345')

    user.website_features << WebsiteFeature.create(:name => :timeline, :last_used => Time.now)
    user.website_features << WebsiteFeature.create(:name => :filtering, :last_used => Time.now)
    user.save!
    user.record_feature_use(:filtering, Time.now)

    user_obj = user.as_json
    assert_equal [:any, :timeline, :filtering, :live_scan, :ad_intelligence, :contacts, :ewok, :search], user_obj[:engagement].map {|x| x['name']}
  end
end
