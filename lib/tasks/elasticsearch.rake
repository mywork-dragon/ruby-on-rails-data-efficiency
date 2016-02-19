# Usage
# cd varys_current && nohup bundle exec rake elasticsearch:run_whatever RAILS_ENV=production > /dev/null 2>&1 &

namespace 'elasticsearch' do

  desc 'IosApp'
  task run_ios_app: [:environment] do
    AppsIndex::IosApp.import
    Slackiq.message(webhook_name: :main, 'IosApp Elasticsearch index completed.')
  end
  
  desc 'AndroidApp'
  task run_android_app: [:environment] do
    AppsIndex::AndroidApp.import
    Slackiq.message(webhook_name: :main, 'AndroidApp Elasticsearch index completed.')
  end

  desc 'IosSdk'
  task run_ios_sdk: [:environment] do
    AppsIndex::IosSdk.import
    Slackiq.message(webhook_name: :main, 'IosSdk Elasticsearch index completed.')
  end
  
  desc 'AndroidSdk'
  task run_android_sdk: [:environment] do
    AppsIndex::AndroidSdk.import
    Slackiq.message(webhook_name: :main, 'AndroidSdk Elasticsearch index completed.')
  end

  desc 'Cocoapod'
  task cocoapod: [:environment] do
    AppsIndex::Cocoapod.import
    Slackiq.message(webhook_name: :main, 'Cocoapod Elasticsearch index completed.')
  end

  desc 'run test'
  task run_test: [:environment] do
    test_method
  end

  def test_method
    puts "test_method called!!"
    sleep(10)
    Slackiq.message(webhook_name: :main, 'hi')
  end

end