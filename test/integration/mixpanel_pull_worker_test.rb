require 'test_helper'

class MixpanelPullWorkerTest < ActiveSupport::TestCase
  class DataGetter
    def users_last_used_events(f)
      return {
        "matt@mightysignal.com" => {timeline: 1, filtering:  Date.new(2016, 12, 1)},
        "matty@mightysignal.com"=> { timeline: Date.new(2016, 12, 1), ad_intelligence: Date.new(2016, 12, 1)}
      }
    end
  end

  test "recoding website feature use" do
    account = Account.create(name: 'MightySignal')
    user1 = User.create(email: 'matt@mightysignal.com', account_id: account.id, password: '12345')
    user2 = User.create(email: 'matty@mightysignal.com', account_id: account.id, password: '12345')
    user1.save!
    user2.save!

    MixpanelPullWorker.new(data_getter = DataGetter.new).perform(Date.new(2016, 11, 1))

    assert_equal ["timeline", "filtering"], user1.website_features.map {|x| x.name}
    assert_equal ["timeline", "ad_intelligence"], user2.website_features.map {|x| x.name}
  end
end
