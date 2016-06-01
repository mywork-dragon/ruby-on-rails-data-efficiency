class ElasticSearchWorker

  include Sidekiq::Worker

  sidekiq_options retry: 5, queue: :default

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def queue_ios_apps
    IosApp.find_in_batches(batch_size: 1000).with_index do |the_batch, index|
      li "App #{index*1000}"
      ids = the_batch.map{ |ios_app| ios_app.id }
      ElasticSearchWorker.perform_async(:index_ios_apps, ids)
    end
  end

  def queue_android_apps
    AndroidApp.find_in_batches(batch_size: 1000).with_index do |the_batch, index|
      li "App #{index*1000}"
      ids = the_batch.map{ |android_app| android_app.id }
      ElasticSearchWorker.perform_async(:index_android_apps, ids)
    end
  end

  def index_ios_apps(app_ids)
    app_ids.each_slice(100) do |ids|
      AppsIndex::IosApp.import(ids)
    end
  end

  def index_android_apps(app_ids)
    app_ids.each_slice(100) do |ids|
      AppsIndex::AndroidApp.import(ids)
    end
  end
end