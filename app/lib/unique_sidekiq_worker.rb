class UniqueSidekiqWorker
  include Sidekiq::Worker

  # How to use this class:
  #
  # Subclass the UniqueSidekiqWorker and set the ttl (in secs) and 
  # key_prefix config values using the unique_worker_options method.
  #
  # Then use the perform_unique and perform_unique_async methods
  # in place of the normal perfom and perform_async methods.
  #
  # Keys for unique tasks are defined as "usw:#{key_prefix}:#{hash of task args}"
  #
  # Example:
  #
  #   class ExampleWorker < UniqueSidekiqWorker
  #     sidekiq_options queue: :test, retry: 2
  #     unique_worker_options ttl: 15, key_prefix: :example
  #
  #     def perform_unique(app_identifier)
  #       puts "I got app #{app_identifier}"
  #     end
  #
  #     def self.queue_app
  #       ExampleWorker.perform_unique_async(1)
  #     end
  #   end

  @@UNIQUE_WORKERS_REDIS = nil

  class << self

    # When a class subclasses UniqueSidekiqWorker, define the
    # perform, and key methods on that subclass.
    def inherited(subclass)
      define_subclass_perform = %Q{
        def perform(*args)
          unlock_and_perform(*args)
        end
      }
      class_eval(define_subclass_perform)
    end 

    def perform_unique_async(*args)
      key_prefix = class_eval("@@key_prefix")
      job_key = generate_job_key(*args)
      full_key = "#{key_prefix}:#{job_key}"

      ttl = class_eval("@@ttl")

      replies = @@UNIQUE_WORKERS_REDIS.multi do
        @@UNIQUE_WORKERS_REDIS.getset(full_key, "1")
        @@UNIQUE_WORKERS_REDIS.expire(full_key, ttl)
      end

      lock_val = replies[0]
      return if lock_val == "1"

      perform_async(*args)
    end

    # Set worker config values as class variables on the subclass.
    # Default TTL value is 1 day.
    def unique_worker_options(key_prefix:, ttl: 86400, use_mock: false)
      initialize_unique_workers_redis(use_mock)
      class_variable_set(:@@ttl, ttl)
      class_variable_set(:@@key_prefix, "usw:#{key_prefix.to_s}")
    end

    def initialize_unique_workers_redis(use_mock)
      if @@UNIQUE_WORKERS_REDIS.nil?
        if use_mock
          # TODO: @@UNIQUE_WORKERS_REDIS = mock_redis
        else
          @@UNIQUE_WORKERS_REDIS = Redis.new(host: ENV['VARYS_REDIS_URL'], port: ENV['VARYS_REDIS_PORT'])
        end
      end
    end

    def generate_job_key(*args)
      Digest::MD5.hexdigest args.to_json
    end

    # Initially attempted to overwrite the perform/perform_async methods, but
    # couldn't find a good way to prepend to the user defined perform method
    # in the subclass. Leaving this code to overwrite the static perform_async
    # method in case we want to change them later.
    #
    # alias :sidekiq_perform_async :perform_async
    # def perform_async(*args)
    #   # Before Hook
    #   sidekiq_perform_async(*args)
    # end

  end

  def unlock_and_perform(*args)
    job_key_prefix = self.class.class_variable_get(:@@key_prefix)
    job_key = UniqueSidekiqWorker.generate_job_key(*args)
    @@UNIQUE_WORKERS_REDIS.del("#{job_key_prefix}:#{job_key}")

    # Don't check that a key was actually deleted in case a job
    # retries.  This may result in some duplicate tasks in the 
    # queue being performed if the ttl isn't set long enough.
    perform_unique(*args)
  end

end
