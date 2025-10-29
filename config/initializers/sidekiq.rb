# Sidekiq configuration
require 'sidekiq'

redis_config = Rails.application.config_for(:redis)

if redis_config
  redis_url = redis_config[:url] || "redis://#{redis_config[:host]}:#{redis_config[:port]}/#{redis_config[:db]}"
  
  Sidekiq.configure_server do |config|
    config.redis = { url: redis_url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url }
  end
end
