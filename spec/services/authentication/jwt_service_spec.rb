require 'rails_helper'

RSpec.describe Services::Authentication::JwtService do
  describe '.encode' do
    it 'encodes payload into JWT token' do
      payload = { user_id: 1, tenant_id: 1 }
      token = described_class.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3)
    end
  end
  
  describe '.decode' do
    it 'decodes valid JWT token' do
      payload = { user_id: 1, tenant_id: 1 }
      token = described_class.encode(payload)
      decoded = described_class.decode(token)
      expect(decoded[:user_id]).to eq(1)
      expect(decoded[:tenant_id]).to eq(1)
    end
    
    it 'returns nil for invalid token' do
      invalid_token = 'invalid.token.here'
      expect(described_class.decode(invalid_token)).to be_nil
    end
  end
  
  describe '.valid_token?' do
    it 'returns true for valid token' do
      token = described_class.encode({ user_id: 1 })
      expect(described_class.valid_token?(token)).to be true
    end
    
    it 'returns false for invalid token' do
      expect(described_class.valid_token?('invalid')).to be false
    end
  end
end
