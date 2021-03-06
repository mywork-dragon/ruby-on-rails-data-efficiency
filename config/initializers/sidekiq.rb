if Rails.env.production?

  if `uname`.chomp == 'Darwin'  # Is a Mac (is Darth Vader)

    Sidekiq.configure_server do |config|
      config.super_fetch!
      config.redis = { url: 'redis://varys-production.bsqwsz.0001.use1.cache.amazonaws.com:6379' }
    end

    Sidekiq.configure_client do |config|
      config.redis = { url: 'redis://varys-production.bsqwsz.0001.use1.cache.amazonaws.com:6379' }
    end

  else  # Is a cloud server

    Sidekiq.configure_server do |config|
      config.super_fetch!
      config.redis = { url: "redis://#{ENV['VARYS_REDIS_URL']}:#{ENV['VARYS_REDIS_PORT']}" }
      config.server_middleware do |chain|
        chain.add Sidekiq::Throttler, storage: :redis
      end
    end

    Sidekiq.configure_client do |config|
      config.redis = { url: "redis://#{ENV['VARYS_REDIS_URL']}:#{ENV['VARYS_REDIS_PORT']}" }
    end

  end



else Rails.env.development?
  Sidekiq.configure_server do |config|
    config.super_fetch!
    config.redis = { url: "redis://#{ENV['VARYS_REDIS_URL']}:#{ENV['VARYS_REDIS_PORT']}" }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: "redis://#{ENV['VARYS_REDIS_URL']}:#{ENV['VARYS_REDIS_PORT']}" }
  end
  
end

if ENV['LOG_LEVEL']
  Sidekiq::Logging.logger.level = ENV['LOG_LEVEL'].downcase.to_sym
end
