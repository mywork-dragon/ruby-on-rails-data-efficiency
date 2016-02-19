namespace 'elasticsearch' do

  desc 'run test'
  task run_test: [:environment] do
    test_method
  end

  desc 'IosApp'
  task run_ios_app: [:environment] do
    AppsIndex::IosApp.import
  end
  
  desc 'AndroidApp'
  task run_android_app: [:environment] do
    AppsIndex::AndroidApp.import
  end

  desc 'IosSdk'
  task run_ios_sdk: [:environment] do
    AppsIndex::IosSdk.import
  end
  
  desc 'AndroidSdk'
  task run_android_sdk: [:environment] do
    AppsIndex::AndroidSdk.import
  end

  desc 'Cocoapod'
  task cocoapod: [:environment] do
    AppsIndex::Cocoapod.import
  end

  def test_method
    puts "test_method called!!"
  end

end