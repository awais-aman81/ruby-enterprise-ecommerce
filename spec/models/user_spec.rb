require 'rails_helper'

RSpec.describe User, type: :model do
  let(:tenant) { Tenant.create!(name: 'Test Tenant', subdomain: 'test', status: 'active') }
  
  describe 'validations' do
    it 'validates presence of email' do
      user = User.new(tenant: tenant, first_name: 'John', last_name: 'Doe', password: 'password123')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end
    
    it 'validates email uniqueness within tenant scope' do
      User.create!(tenant: tenant, email: 'test@example.com', first_name: 'John', 
                   last_name: 'Doe', password: 'password123')
      duplicate = User.new(tenant: tenant, email: 'test@example.com', first_name: 'Jane', 
                          last_name: 'Doe', password: 'password123')
      expect(duplicate).not_to be_valid
    end
    
    it 'validates password length' do
      user = User.new(tenant: tenant, email: 'test@example.com', first_name: 'John', 
                     last_name: 'Doe', password: '123')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 8 characters)')
    end
  end
  
  describe 'methods' do
    let(:user) { User.create!(tenant: tenant, email: 'test@example.com', first_name: 'John', 
                             last_name: 'Doe', password: 'password123') }
    
    it 'returns full name' do
      expect(user.full_name).to eq('John Doe')
    end
    
    it 'checks if user is active' do
      expect(user.active?).to be true
    end
  end
end
