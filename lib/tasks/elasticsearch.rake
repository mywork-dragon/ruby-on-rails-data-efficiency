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

  desc 'IosSdk'
  task run_ios_sdk: [:environment] do |task|
    notify_start(task.full_comment)
    AppsIndex::IosSdk.import
    notify_end(task.full_comment)
  end
  
  desc 'AndroidSdk'
  task run_android_sdk: [:environment] do |task|
    notify_start(task.full_comment)
    AppsIndex::AndroidSdk.import
    notify_end(task.full_comment)
  end

  desc 'Cocoapod'
  task cocoapod: [:environment] do |task|
    notify_start(task.full_comment)
    AppsIndex::Cocoapod.import
    notify_end(task.full_comment)
  end

  desc 'run test'
  task run_test: [:environment] do |task|
    puts "I am running #{task.full_comment}"
  end

  def notify_start(name)
    message = "#{name} Elasticsearch index started."
    puts message
    Slackiq.message(message, webhook_name: :main)
  end

  def notify_end(name)
    message = "#{name} Elasticsearch index completed."
    puts message
    Slackiq.message(message, webhook_name: :main)
  end

end