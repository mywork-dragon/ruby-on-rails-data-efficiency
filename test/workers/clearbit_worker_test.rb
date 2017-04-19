require 'test_helper'
require 'sidekiq/testing'

class ClearbitWorkerTest < ActiveSupport::TestCase
  def setup
    (0..99).each do |id|
      AndroidApp.create!(:app_identifier => id.to_s, :user_base => 0)
      IosApp.create!(:app_identifier => id.to_s, :user_base => 0)
    end
    Sidekiq::Testing.fake!
  end

  # disable until figure out redis solution
  # test 'queues subset of apps' do
  #   apps = ClearbitWorker.new.queue_n_apps_for_enrichment(2)
  #   assert_equal 1, apps['ios_apps'].count
  #   assert_equal 1, apps['android_apps'].count
  # end

  # test 'queues all of apps' do
  #   apps = ClearbitWorker.new.queue_n_apps_for_enrichment(300)
  #   assert_equal 100, apps['ios_apps'].count
  #   assert_equal 100, apps['android_apps'].count
  # end

  # test "doesn't queue already enriched apps." do
  #   app = AndroidApp.find_by_app_identifier('0')

  #   app.android_developer = AndroidDeveloper.create()
  #   app.android_developer.valid_websites << Website.create(:url => 'http://test1.com')
  #   dd = DomainDatum.create(:country_code => 'US', :websites => app.android_developer.valid_websites)
  #   adw =  AndroidDevelopersWebsite.last
  #   adw.is_valid = true
  #   adw.save!
  #   app.android_developer.save!
  #   app.save!
  #   apps = ClearbitWorker.new.queue_n_apps_for_enrichment(300)
  #   assert_equal 99, apps['android_apps'].count
  # end

end
