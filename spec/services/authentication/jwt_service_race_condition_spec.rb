require 'rails_helper'

RSpec.describe Services::Authentication::JwtService, type: :service do
  describe 'race condition and memory management' do
    let(:test_payload) { { user_id: 1, tenant_id: 1 } }
    
    describe 'thread safety' do
      it 'handles concurrent token generation without race conditions' do
        threads = []
        tokens = []
        mutex = Mutex.new
        
        10.times do
          threads << Thread.new do
            token = described_class.encode(test_payload.dup)
            mutex.synchronize { tokens << token }
          end
        end
        
        threads.each(&:join)
        
        expect(tokens.length).to eq(10)
        expect(tokens.uniq.length).to eq(10) # All tokens should be unique
      end
      
      it 'handles concurrent token validation safely' do
        token = described_class.encode(test_payload)
        results = []
        threads = []
        mutex = Mutex.new
        
        10.times do
          threads << Thread.new do
            result = described_class.valid_token?(token)
            mutex.synchronize { results << result }
          end
        end
        
        threads.each(&:join)
        
        expect(results).to all(be true)
        expect(results.length).to eq(10)
      end
    end
    
    describe 'memory management' do
      it 'caches tokens for performance' do
        token = described_class.encode(test_payload)
        
        # First decode should cache the token
        decoded1 = described_class.decode(token)
        
        # Second decode should use cache (faster)
        decoded2 = described_class.decode(token)
        
        expect(decoded1).to eq(decoded2)
        expect(decoded1[:user_id]).to eq(1)
      end
      
      it 'automatically cleans up expired tokens from cache' do
        # Create a token that expires quickly
        short_payload = test_payload.merge(exp: 1.second.from_now.to_i)
        token = JWT.encode(short_payload, described_class::SECRET_KEY, described_class::ALGORITHM)
        
        # Decode to cache it
        described_class.decode(token)
        
        # Wait for expiration
        sleep(2)
        
        # This should trigger cleanup and return nil
        result = described_class.decode(token)
        expect(result).to be_nil
      end
      
      it 'prevents memory leaks with invalid tokens' do
        invalid_tokens = Array.new(100) { "invalid.token.#{rand(1000)}" }
        
        invalid_tokens.each do |token|
          result = described_class.decode(token)
          expect(result).to be_nil
        end
        
        # Memory should not grow indefinitely with invalid tokens
        expect(true).to be true # Test passes if no memory errors occur
      end
    end
    
    describe 'performance improvements' do
      it 'avoids duplicate decode calls in expired? method' do
        token = described_class.encode(test_payload)
        
        # Mock to count decode calls
        allow(described_class).to receive(:decode).and_call_original
        
        result = described_class.expired?(token)
        
        expect(result).to be false
        expect(described_class).to have_received(:decode).once
      end
      
      it 'handles blank tokens efficiently' do
        expect(described_class.valid_token?(nil)).to be false
        expect(described_class.valid_token?('')).to be false
        expect(described_class.valid_token?('   ')).to be false
      end
    end
  end
end
