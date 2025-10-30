module Services
  module Authentication
    class JwtService
      SECRET_KEY = Rails.application.secret_key_base
      ALGORITHM = 'HS256'
      EXPIRATION_TIME = 24.hours
      
      # Thread-safe token cache with automatic cleanup
      @token_cache = {}
      @cache_mutex = Mutex.new
      @last_cleanup = Time.current
      
      class << self
        def encode(payload)
          @cache_mutex.synchronize do
            payload[:exp] = EXPIRATION_TIME.from_now.to_i
            payload[:iat] = Time.current.to_i
            payload[:jti] = SecureRandom.uuid # Add unique token ID
            
            token = JWT.encode(payload, SECRET_KEY, ALGORITHM)
            cache_token(token, payload[:exp])
            token
          end
        end
        
        def decode(token)
          # Check cache first for performance
          cached_payload = get_cached_token(token)
          return cached_payload if cached_payload
          
          @cache_mutex.synchronize do
            decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
            payload = decoded[0].with_indifferent_access
            cache_token(token, payload[:exp]) if payload[:exp]
            payload
          end
        rescue JWT::DecodeError => e
          Rails.logger.error "JWT decode error: #{e.message}"
          cleanup_expired_tokens
          nil
        end
        
        def valid_token?(token)
          return false if token.blank?
          
          payload = decode(token)
          return false unless payload
          
          !expired_payload?(payload)
        end
        
        def expired?(token)
          payload = decode(token)
          return true unless payload
          
          expired_payload?(payload)
        end
        
        private
        
        def cache_token(token, expiration)
          cleanup_expired_tokens if should_cleanup?
          @token_cache[token] = {
            payload: decode_without_cache(token),
            expires_at: Time.at(expiration)
          }
        end
        
        def get_cached_token(token)
          @cache_mutex.synchronize do
            cached = @token_cache[token]
            return nil unless cached
            
            if cached[:expires_at] > Time.current
              cached[:payload]
            else
              @token_cache.delete(token)
              nil
            end
          end
        end
        
        def decode_without_cache(token)
          decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
          decoded[0].with_indifferent_access
        rescue JWT::DecodeError
          nil
        end
        
        def expired_payload?(payload)
          Time.current.to_i > payload[:exp].to_i
        end
        
        def cleanup_expired_tokens
          current_time = Time.current
          @token_cache.delete_if { |_, cached| cached[:expires_at] <= current_time }
          @last_cleanup = current_time
        end
        
        def should_cleanup?
          Time.current - @last_cleanup > 1.hour
        end
      end
    end
  end
end
