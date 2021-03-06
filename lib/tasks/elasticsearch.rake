# Usage
# cd varys_current && nohup bundle exec rake elasticsearch:run_whatever RAILS_ENV=production > ~/elasticsearch.log 2>&1 &

namespace 'elasticsearch' do

  # So we can pull data from the task object in the task blocks
  Rake::TaskManager.record_task_metadata = true

  desc 'IosApp'
  task run_ios_app: [:environment] do |task|
    notify_start(task.full_comment)
    AppsIndex::IosApp.import
    notify_end(task.full_comment)
  end
  
  desc 'AndroidApp'
  task run_android_app: [:environment] do |task|
    notify_start(task.full_comment)
    AppsIndex::AndroidApp.import
    notify_end(task.full_comment)
  end

  desc 'rebuild IosSdk'
  task rebuild_ios_sdk: [:environment] do |task|
    notify_start(task.full_comment)
    IosSdkIndex.reset!
    notify_end(task.full_comment)
  end

  desc 'update IosSdk'
  task update_ios_sdk: [:environment] do |task|
    notify_start(task.full_comment)
    IosSdkIndex.import
    notify_end(task.full_comment)
  end

  desc 'rebuild AndroidSdk'
  task rebuild_android_sdk: [:environment] do |task|
    notify_start(task.full_comment)
    AndroidSdkIndex.reset!
    notify_end(task.full_comment)
  end

  desc 'update AndroidSdk'
  task update_android_sdk: [:environment] do |task|
    notify_start(task.full_comment)
    AndroidSdkIndex.import
    notify_end(task.full_comment)
  end
  
  desc 'AndroidSdk'
  task run_android_sdk: [:environment] do |task|
    notify_start(task.full_comment)
    AppsIndex::AndroidSdk.import
    notify_end(task.full_comment)
  end

  desc 'run test'
  task run_test: [:environment] do |task|
    puts "I am running #{task.full_comment}"
  end

  def notify_start(name)
    message = "#{name} Elasticsearch index started."
    puts message
    Slackiq.message(message, webhook_name: :main) unless Rails.env.development?
  end

  def notify_end(name)
    message = "#{name} Elasticsearch index completed."
    puts message
    Slackiq.message(message, webhook_name: :main) unless Rails.env.development?
  end

end
