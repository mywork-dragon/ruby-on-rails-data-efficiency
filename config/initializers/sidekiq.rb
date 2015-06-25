if Rails.env.production?

  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://varys-production.bsqwsz.0001.use1.cache.amazonaws.com:6379' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://varys-production.bsqwsz.0001.use1.cache.amazonaws.com:6379' }
  end

elsif Rails.env.development?
  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://localhost:6379' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://localhost:6379' }
  end
  
end
