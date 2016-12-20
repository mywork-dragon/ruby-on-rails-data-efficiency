class SidekiqBatchQueueWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :sidekiq_batcher, retry: false

  def perform(class_name, args, bid, specified_queue = nil)
    batch = Sidekiq::Batch.new(bid)

    worker_class = class_name.constantize
    queue = (specified_queue || worker_class.sidekiq_options['queue']).to_s

    batch.jobs do
      Sidekiq::Client.push_bulk(
        'class' => worker_class,
        'args' => args,
        'queue' => queue
      )
    end
  end
end
