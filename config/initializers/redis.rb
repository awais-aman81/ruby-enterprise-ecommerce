# Redis configuration
redis_config = Rails.application.config_for(:redis)

$redis = Redis.new(redis_config) if redis_config

# Configure Rails cache to use Redis
Rails.application.configure do
  config.cache_store = :redis_cache_store, {
    url: redis_config&.dig(:url) || "redis://#{redis_config&.dig(:host) || 'localhost'}:#{redis_config&.dig(:port) || 6379}/#{redis_config&.dig(:db) || 0}"
  }
end
