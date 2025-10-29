require 'rails_helper'

RSpec.describe Tenant, type: :model do
  describe 'validations' do
    it 'validates presence of name' do
      tenant = Tenant.new(subdomain: 'test', status: 'active')
      expect(tenant).not_to be_valid
      expect(tenant.errors[:name]).to include("can't be blank")
    end
    
    it 'validates uniqueness of subdomain' do
      Tenant.create!(name: 'Test', subdomain: 'test', status: 'active')
      duplicate = Tenant.new(name: 'Test 2', subdomain: 'test', status: 'active')
      expect(duplicate).not_to be_valid
    end
    
    it 'validates subdomain format' do
      tenant = Tenant.new(name: 'Test', subdomain: 'Test_123', status: 'active')
      expect(tenant).not_to be_valid
      expect(tenant.errors[:subdomain]).to include('only lowercase letters, numbers, and hyphens allowed')
    end
  end
  
  describe 'scopes' do
    it 'returns active tenants' do
      active_tenant = Tenant.create!(name: 'Active', subdomain: 'active', status: 'active')
      inactive_tenant = Tenant.create!(name: 'Inactive', subdomain: 'inactive', status: 'inactive')
      expect(Tenant.active).to include(active_tenant)
      expect(Tenant.active).not_to include(inactive_tenant)
    end
  end
end
