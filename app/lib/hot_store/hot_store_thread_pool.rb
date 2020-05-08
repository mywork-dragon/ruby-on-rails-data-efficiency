class HotStoreThreadPool

  @@STARTUP_NODES = [
    {:host => ENV['HOT_STORE_REDIS_URL'], :port => ENV['HOT_STORE_REDIS_PORT'] }
  ]

  @@MAX_CONNECTIONS = (ENV['HOT_STORE_REDIS_MAX_CONNECTIONS'] || 1).to_i
  
  # Add sidekiq concurrency to connection pool size since writes will
  # run on main sidekiq threads if queue is backed up.
  @@SIDEKIQ_CONCURRENCY = (ENV['SIDEKIQ_CONCURRENCY'] || 1).to_i

  @@NUM_THREADS = 5

  @@thread_pool = nil
  @@connection_pool = nil

  class << self
    def instance 
      if @@thread_pool.nil?
        @@thread_pool = Concurrent::ThreadPoolExecutor.new(
          min_threads: @@NUM_THREADS,
          max_threads: @@NUM_THREADS,
          max_queue: 100,
          fallback_policy: :caller_runs
        )
      end
      @@thread_pool
    end

    def connection_pool
      if @@connection_pool.nil?
        pool_options = {
          size: @@NUM_THREADS + @@SIDEKIQ_CONCURRENCY,
          timeout: 15,
          health_check: lambda {|conn| conn.echo "ping"}
        }

        @@connection_pool = HealthyPools.new(pool_options) { 
          RedisCluster.new(@@STARTUP_NODES, @@MAX_CONNECTIONS) 
        }
      end
      @@connection_pool
    end
  end

end