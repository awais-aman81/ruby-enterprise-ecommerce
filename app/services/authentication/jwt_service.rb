module Services
  module Authentication
    class JwtService
      SECRET_KEY = Rails.application.secret_key_base
      ALGORITHM = 'HS256'
      EXPIRATION_TIME = 24.hours
      
      def self.encode(payload)
        payload[:exp] = EXPIRATION_TIME.from_now.to_i
        payload[:iat] = Time.current.to_i
        JWT.encode(payload, SECRET_KEY, ALGORITHM)
      end
      
      def self.decode(token)
        decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
        decoded[0].with_indifferent_access
      rescue JWT::DecodeError => e
        Rails.logger.error "JWT decode error: #{e.message}"
        nil
      end
      
      def self.valid_token?(token)
        !!decode(token)
      end
      
      def self.expired?(token)
        decoded = decode(token)
        return true unless decoded
        
        Time.current.to_i > decoded[:exp]
      end
    end
  end
end
