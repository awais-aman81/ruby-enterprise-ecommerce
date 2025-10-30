require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:tenant) { Tenant.create!(name: 'Test Tenant', subdomain: 'test', status: 'active') }
  
  describe 'validations' do
    it 'validates presence of name' do
      category = Category.new(tenant: tenant, status: 'active')
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end
    
    it 'validates uniqueness of slug within tenant scope' do
      Category.create!(tenant: tenant, name: 'Electronics', status: 'active')
      duplicate = Category.new(tenant: tenant, name: 'Electronics', status: 'active')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to include('has already been taken')
    end
    
    it 'validates parent belongs to same tenant' do
      other_tenant = Tenant.create!(name: 'Other', subdomain: 'other', status: 'active')
      parent = Category.create!(tenant: other_tenant, name: 'Parent', status: 'active')
      child = Category.new(tenant: tenant, name: 'Child', parent: parent, status: 'active')
      
      expect(child).not_to be_valid
      expect(child.errors[:parent]).to include('must belong to the same tenant')
    end
  end
  
  describe 'hierarchical structure' do
    let(:parent) { Category.create!(tenant: tenant, name: 'Electronics', status: 'active') }
    let(:child) { Category.create!(tenant: tenant, name: 'Smartphones', parent: parent, status: 'active') }
    
    it 'identifies root categories' do
      expect(parent.root?).to be true
      expect(child.root?).to be false
    end
    
    it 'identifies leaf categories' do
      expect(parent.leaf?).to be false
      expect(child.leaf?).to be true
    end
    
    it 'returns correct ancestors' do
      expect(child.ancestors).to eq([parent])
      expect(parent.ancestors).to eq([])
    end
  end
  
  describe 'slug generation' do
    it 'generates slug from name' do
      category = Category.create!(tenant: tenant, name: 'Consumer Electronics', status: 'active')
      expect(category.slug).to eq('consumer-electronics')
    end
  end
end
