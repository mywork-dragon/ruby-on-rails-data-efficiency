# It seems the main reason of this class is to use Sidekiq::Client.push_bulk in
# Order to create the individual jobs, since according do docu:

# Push a large number of jobs to Redis. This method cuts out the
# redis network round trip latency. I wouldn't recommend pushing more than 1000
# per call but YMMV based on network quality, size of job args, etc.
# A large number of jobs can cause a bit of Redis command processing latency.

class SidekiqBatchQueueWorker
  include Sidekiq::Worker

  sidekiq_options queue: :sidekiq_batcher, retry: false

  def perform(class_name, args, bid, specified_queue = nil)
    batch = Sidekiq::Batch.new(bid) #what's the reason of reusing the batch?

    worker_class = class_name.constantize
    queue = (specified_queue || worker_class.sidekiq_options['queue']).to_s
    
    if ENV['JOBS_PERFORM_INLINE']
      batch.jobs { args.each { |job_args| worker_class.new.perform(*job_args) } }
    else
      batch.jobs { Sidekiq::Client.push_bulk( 'class' => worker_class, 'args' => args, 'queue' => queue ) }
    end
  end
end
